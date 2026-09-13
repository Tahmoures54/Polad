import 'dart:async';

import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/app_result.dart';
import '../../core/error/failure.dart';
import '../../core/network/guard.dart';
import '../../core/network/network_retry.dart';
import '../../core/utils/phone.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/people.dart';
import '../demo/demo_backend.dart';
import '../models/models.dart';

/// نتیجه ارسال OTP برای ورود با شماره موبایل.
class OtpDispatch {
  const OtpDispatch({
    required this.verificationId,
    this.resendToken,
    this.autoVerified = false,
  });

  /// شناسه جلسه تأیید Firebase (در دمو یک مقدار ساختگی است).
  final String verificationId;

  /// توکن ارسال مجدد برای جلوگیری از سهمیه اضافه.
  final int? resendToken;

  /// اگر Play Services کد را خودکار بخواند و وارد کند.
  final bool autoVerified;
}

/// ادعاهای سفارشی JWT (نقش سراسری؛ نقش عملیاتی هر صندوق در عضویت است).
class AuthClaims {
  const AuthClaims({
    this.role,
    this.fundId,
    this.raw = const {},
  });

  final UserRole? role;
  final String? fundId;
  final Map<String, dynamic> raw;

  bool get isAdmin => role == UserRole.admin;
}

/// لایه احراز هویت: OTP، خروج، وضعیت نشست و Custom Claims.
///
/// تنظیم Claims فقط از طریق Cloud Functions / Admin SDK ممکن است؛ کلاینت
/// مستقیم به `setCustomUserClaims` دسترسی ندارد.
abstract class AuthService {
  /// جریان وضعیت ورود؛ `null` یعنی مهمان.
  Stream<User?> authStateChanges();

  /// کاربر فعلی بر اساس توکن (پروفایل کامل ممکن است در Firestore باشد).
  User? get currentUser;

  /// شناسه Firebase کاربر فعلی.
  String? get currentUid;

  /// ارسال کد ۶ رقمی به شماره موبایل ایران.
  Future<AppResult<OtpDispatch>> sendOtp(
    String phone, {
    int? resendToken,
  });

  /// تأیید کد و ورود؛ اگر پروفایل نباشد ساخته می‌شود.
  Future<AppResult<User>> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phone,
  });

  /// خروج از حساب و پاک‌کردن نشست محلی.
  Future<AppResult<Unit>> signOut();

  /// خواندن Custom Claims از توکن فعلی.
  Future<AppResult<AuthClaims>> readCustomClaims({bool forceRefresh = false});

  /// تنظیم Claims از طریق Cloud Function (فقط مدیر صندوق).
  Future<AppResult<Unit>> setCustomClaims({
    required String uid,
    required UserRole role,
    String? fundId,
  });
}

/// پیاده‌سازی Firebase Auth با retry برای خطاهای گذرای شبکه.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService(
    this._auth,
    this._readProfile,
    this._persistProfile,
    this._setClaims, {
    NetworkRetry? retry,
  }) : _retry = retry ?? NetworkRetry.standard;

  final fa.FirebaseAuth _auth;
  final Future<AppResult<User>> Function(String uid) _readProfile;
  final Future<AppResult<Unit>> Function(User user) _persistProfile;
  final Future<AppResult<Unit>> Function({
    required String uid,
    required UserRole role,
    String? fundId,
  }) _setClaims;
  final NetworkRetry _retry;

  @override
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((fb) async {
      if (fb == null) return null;
      final existing = await _readProfile(fb.uid);
      return existing.fold((_) => _fromFirebase(fb, fb.phoneNumber ?? ''), (u) => u);
    });
  }

  @override
  User? get currentUser {
    final fb = _auth.currentUser;
    if (fb == null) return null;
    return _fromFirebase(fb, fb.phoneNumber ?? '');
  }

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Future<AppResult<OtpDispatch>> sendOtp(
    String phone, {
    int? resendToken,
  }) {
    if (!IranianPhone.isValid(phone)) {
      return Future.value(left(const AuthFailure(message: 'شماره موبایل معتبر نیست')));
    }
    final e164 = IranianPhone.toE164(phone);
    return guardNetwork(() async {
      final completer = Completer<OtpDispatch>();
      await _auth.verifyPhoneNumber(
        phoneNumber: e164,
        forceResendingToken: resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (cred) async {
          await _auth.signInWithCredential(cred);
          if (!completer.isCompleted) {
            completer.complete(
              const OtpDispatch(verificationId: 'auto', autoVerified: true),
            );
          }
        },
        verificationFailed: (e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
        codeSent: (id, token) {
          if (!completer.isCompleted) {
            completer.complete(OtpDispatch(verificationId: id, resendToken: token));
          }
        },
        codeAutoRetrievalTimeout: (id) {
          if (!completer.isCompleted) {
            completer.complete(OtpDispatch(verificationId: id));
          }
        },
      );
      return completer.future;
    }, retry: _retry);
  }

  @override
  Future<AppResult<User>> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phone,
  }) {
    return guardNetwork(() async {
      if (verificationId == 'auto' && _auth.currentUser != null) {
        return _mapAndPersist(_auth.currentUser!, phone);
      }
      final cred = fa.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final res = await _auth.signInWithCredential(cred);
      final fb = res.user;
      if (fb == null) {
        throw const AuthFailure(message: 'ورود ناموفق بود');
      }
      return _mapAndPersist(fb, phone);
    }, retry: _retry);
  }

  Future<User> _mapAndPersist(fa.User fb, String phone) async {
    final existing = await _readProfile(fb.uid);
    final found = existing.fold<User?>((_) => null, (u) => u);
    if (found != null) return found;
    final user = _fromFirebase(fb, phone);
    final saved = await _persistProfile(user);
    saved.fold((f) => throw f, (_) {});
    return user;
  }

  User _fromFirebase(fa.User fb, String phone) {
    final rawPhone = phone.isEmpty ? (fb.phoneNumber ?? '') : phone;
    return User(
      uid: fb.uid,
      name: fb.displayName ?? '',
      phone: IranianPhone.normalize(rawPhone),
      role: UserRole.member,
      fundIds: const [],
      createdAt: fb.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Future<AppResult<Unit>> signOut() {
    return guardNetwork(() async {
      await _auth.signOut();
      return unit;
    }, retry: _retry);
  }

  @override
  Future<AppResult<AuthClaims>> readCustomClaims({bool forceRefresh = false}) {
    return guardNetwork(() async {
      final fb = _auth.currentUser;
      if (fb == null) throw const AuthFailure(message: 'کاربر وارد نشده است');
      final token = await fb.getIdTokenResult(forceRefresh);
      final claims = token.claims ?? {};
      final roleRaw = claims['role']?.toString();
      return AuthClaims(
        role: roleRaw == UserRole.admin.firestoreValue ? UserRole.admin : UserRole.member,
        fundId: claims['fundId']?.toString(),
        raw: Map<String, dynamic>.from(claims),
      );
    }, retry: _retry);
  }

  @override
  Future<AppResult<Unit>> setCustomClaims({
    required String uid,
    required UserRole role,
    String? fundId,
  }) {
    return _setClaims(uid: uid, role: role, fundId: fundId);
  }
}

/// حالت دمو: OTP ثابت [AppConstants.demoOtp] بدون Firebase.
class DemoAuthService implements AuthService {
  DemoAuthService(this._demo);

  final DemoStore _demo;

  User? _map(UserProfile? src) {
    if (src == null) return null;
    final isAdmin = src.phone == AppConstants.demoAdminPhone ||
        (src.activeFundId != null && _demo.isAdmin(src.activeFundId!));
    return User(
      uid: src.id,
      name: src.displayName,
      phone: src.phone,
      role: isAdmin ? UserRole.admin : UserRole.member,
      fundIds: src.fundIds,
      createdAt: src.createdAt,
    );
  }

  @override
  Stream<User?> authStateChanges() async* {
    yield _map(_demo.currentUser);
    yield* _demo.authController.stream.map(_map);
  }

  @override
  User? get currentUser => _map(_demo.currentUser);

  @override
  String? get currentUid => _demo.currentUser?.id;

  @override
  Future<AppResult<OtpDispatch>> sendOtp(String phone, {int? resendToken}) async {
    if (!IranianPhone.isValid(phone)) {
      return left(const AuthFailure(message: 'شماره موبایل معتبر نیست'));
    }
    _demo.pendingPhone = IranianPhone.normalize(phone);
    debugPrint('دمو: کد تأیید ${AppConstants.demoOtp} است');
    return right(
      OtpDispatch(verificationId: 'demo-${IranianPhone.normalize(phone)}', resendToken: resendToken),
    );
  }

  @override
  Future<AppResult<User>> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phone,
  }) async {
    final code = Validators.toEnglishDigits(smsCode);
    if (code != AppConstants.demoOtp) {
      return left(const AuthFailure(message: 'کد تأیید نادرست است. در حالت آزمایشی کد ۱۲۳۴۵۶ است.'));
    }
    final normalized = IranianPhone.normalize(phone);
    final existing = _demo.users.values.where((u) => u.phone == normalized).firstOrNull;
    final UserProfile profile;
    if (existing != null) {
      profile = existing;
    } else {
      final id = _demo.newId();
      profile = UserProfile(
        id: id,
        phone: normalized,
        displayName: 'کاربر جدید',
        createdAt: DateTime.now(),
      );
      _demo.users[id] = profile;
    }
    _demo.currentUser = profile;
    _demo.authController.add(profile);
    await _demo.persist();
    return right(_map(profile)!);
  }

  @override
  Future<AppResult<Unit>> signOut() async {
    _demo.currentUser = null;
    _demo.authController.add(null);
    await _demo.persist();
    return right(unit);
  }

  @override
  Future<AppResult<AuthClaims>> readCustomClaims({bool forceRefresh = false}) async {
    final user = currentUser;
    if (user == null) return left(const AuthFailure(message: 'کاربر وارد نشده است'));
    return right(
      AuthClaims(
        role: user.role,
        fundId: _demo.currentUser?.activeFundId,
      ),
    );
  }

  @override
  Future<AppResult<Unit>> setCustomClaims({
    required String uid,
    required UserRole role,
    String? fundId,
  }) async {
    return right(unit);
  }
}
