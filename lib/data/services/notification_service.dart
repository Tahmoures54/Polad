import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/error/app_result.dart';
import '../../core/error/failure.dart';
import '../../core/network/guard.dart';
import '../../core/network/network_retry.dart';
import '../../firebase_options.dart';

/// کانال اندروید برای اعلان‌های محلی پولاد.
const poladNotificationChannelId = 'polad_default';
const poladNotificationChannelName = 'اعلان‌های پولاد';

/// هندلر پس‌زمینه FCM باید سطح بالا باشد (نه متد کلاس).
@pragma('vm:entry-point')
Future<void> poladFirebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
}

/// پیام اعلان نرمال‌شده برای لایه نمایش.
class PushMessage {
  const PushMessage({
    required this.title,
    required this.body,
    this.data = const {},
    this.messageId,
  });

  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? messageId;

  factory PushMessage.fromRemote(RemoteMessage message) {
    return PushMessage(
      title: message.notification?.title ?? message.data['title']?.toString() ?? 'پولاد',
      body: message.notification?.body ?? message.data['body']?.toString() ?? '',
      data: Map<String, dynamic>.from(message.data),
      messageId: message.messageId,
    );
  }
}

/// FCM + اعلان محلی + عضویت در topic صندوق.
abstract class NotificationService {
  /// درخواست مجوز، ساخت کانال، ثبت هندلر و ذخیره توکن.
  Future<AppResult<Unit>> initialize();

  /// توکن فعلی دستگاه برای ارسال هدفمند.
  Future<AppResult<String?>> getToken();

  /// جریان پیام‌های پیش‌زمینه.
  Stream<PushMessage> get onMessage;

  /// نمایش اعلان محلی (وقتی اپ باز است FCM UI نشان نمی‌دهد).
  Future<AppResult<Unit>> showLocal({
    required String title,
    required String body,
    String? payload,
  });

  /// عضویت در topic صندوق تا همه اعضا اعلان مشترک بگیرند.
  Future<AppResult<Unit>> subscribeToFund(String fundId);

  /// لغو عضویت topic هنگام خروج از صندوق.
  Future<AppResult<Unit>> unsubscribeFromFund(String fundId);

  /// topic کاربر برای پیام شخصی.
  Future<AppResult<Unit>> subscribeToUser(String uid);

  Future<AppResult<Unit>> unsubscribeFromUser(String uid);
}

/// پیاده‌سازی Firebase Cloud Messaging + flutter_local_notifications.
class FirebaseNotificationService implements NotificationService {
  FirebaseNotificationService(
    this._messaging,
    this._local,
    this._persistToken, {
    NetworkRetry? retry,
  }) : _retry = retry ?? NetworkRetry.standard;

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;
  final Future<void> Function(String token) _persistToken;
  final NetworkRetry _retry;
  final _controller = StreamController<PushMessage>.broadcast();
  var _initialized = false;

  @override
  Stream<PushMessage> get onMessage => _controller.stream;

  @override
  Future<AppResult<Unit>> initialize() {
    return guardNetwork(() async {
      if (_initialized) return unit;
      FirebaseMessaging.onBackgroundMessage(poladFirebaseMessagingBackgroundHandler);

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _local.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
      );

      const channel = AndroidNotificationChannel(
        poladNotificationChannelId,
        poladNotificationChannelName,
        description: 'یادآوری قسط، تأیید تراکنش و پیام‌های صندوق',
        importance: Importance.high,
      );
      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen((msg) async {
        final push = PushMessage.fromRemote(msg);
        _controller.add(push);
        await showLocal(title: push.title, body: push.body, payload: push.messageId);
      });

      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _persistToken(token);
      }
      _messaging.onTokenRefresh.listen(_persistToken);
      _initialized = true;
      return unit;
    }, retry: _retry);
  }

  @override
  Future<AppResult<String?>> getToken() {
    return guardNetwork(_messaging.getToken, retry: _retry);
  }

  @override
  Future<AppResult<Unit>> showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const android = AndroidNotificationDetails(
        poladNotificationChannelId,
        poladNotificationChannelName,
        importance: Importance.high,
        priority: Priority.high,
      );
      const ios = DarwinNotificationDetails();
      await _local.show(
        DateTime.now().millisecondsSinceEpoch.remainder(0x7fffffff),
        title,
        body,
        const NotificationDetails(android: android, iOS: ios),
        payload: payload,
      );
      return right(unit);
    } catch (e, st) {
      return left(Failure.from(e, st));
    }
  }

  @override
  Future<AppResult<Unit>> subscribeToFund(String fundId) => _subscribe('fund_$fundId');

  @override
  Future<AppResult<Unit>> unsubscribeFromFund(String fundId) => _unsubscribe('fund_$fundId');

  @override
  Future<AppResult<Unit>> subscribeToUser(String uid) => _subscribe('user_$uid');

  @override
  Future<AppResult<Unit>> unsubscribeFromUser(String uid) => _unsubscribe('user_$uid');

  Future<AppResult<Unit>> _subscribe(String topic) {
    return guardNetwork(() async {
      await _messaging.subscribeToTopic(topic);
      return unit;
    }, retry: _retry);
  }

  Future<AppResult<Unit>> _unsubscribe(String topic) {
    return guardNetwork(() async {
      await _messaging.unsubscribeFromTopic(topic);
      return unit;
    }, retry: _retry);
  }
}

/// دمو: توکن ساختگی و اعلان‌های درون‌حافظه (بدون سیستم‌عامل).
class DemoNotificationService implements NotificationService {
  DemoNotificationService();

  final _controller = StreamController<PushMessage>.broadcast();
  final subscribed = <String>{};
  final localShown = <PushMessage>[];
  String? token = 'demo-fcm-token';

  @override
  Stream<PushMessage> get onMessage => _controller.stream;

  @override
  Future<AppResult<Unit>> initialize() async => right(unit);

  @override
  Future<AppResult<String?>> getToken() async => right(token);

  @override
  Future<AppResult<Unit>> showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    final msg = PushMessage(title: title, body: body, data: {'payload': payload});
    localShown.add(msg);
    _controller.add(msg);
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> subscribeToFund(String fundId) async {
    subscribed.add('fund_$fundId');
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> unsubscribeFromFund(String fundId) async {
    subscribed.remove('fund_$fundId');
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> subscribeToUser(String uid) async {
    subscribed.add('user_$uid');
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> unsubscribeFromUser(String uid) async {
    subscribed.remove('user_$uid');
    return right(unit);
  }
}
