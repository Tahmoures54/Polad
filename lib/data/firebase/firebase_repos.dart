import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/people.dart';
import '../../domain/repositories/repositories.dart';

Map<String, dynamic> _withDates(Map<String, dynamic> map) {
  final out = Map<String, dynamic>.from(map);
  for (final key in out.keys.toList()) {
    final v = out[key];
    if (v is Timestamp) out[key] = v.toDate().toIso8601String();
  }
  return out;
}

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  String? _verificationId;
  UserProfile? _cached;

  @override
  UserProfile? get currentUser => _cached;

  @override
  Stream<UserProfile?> authState() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        _cached = null;
        return null;
      }
      final doc = await _db.collection(CollectionPaths.users).doc(user.uid).get();
      if (!doc.exists) {
        _cached = UserProfile(
          id: user.uid,
          phone: user.phoneNumber ?? '',
          displayName: '',
          createdAt: DateTime.now(),
        );
        return _cached;
      }
      _cached = UserProfile.fromMap(_withDates({'id': doc.id, ...doc.data()!}));
      return _cached;
    });
  }

  @override
  Future<Result<void>> sendOtp(String phone) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _toE164(phone),
        verificationCompleted: (_) {},
        verificationFailed: (e) {},
        codeSent: (id, _) => _verificationId = id,
        codeAutoRetrievalTimeout: (id) => _verificationId = id,
        timeout: const Duration(seconds: 60),
      );
      return const Ok(null);
    } on FirebaseAuthException catch (e) {
      return Err(e.message ?? 'ارسال پیامک ناموفق بود');
    }
  }

  @override
  Future<Result<UserProfile>> verifyOtp({
    required String phone,
    required String smsCode,
    String? displayName,
  }) async {
    try {
      final id = _verificationId;
      if (id == null) return const Err('ابتدا درخواست کد بدهید');
      final cred = PhoneAuthProvider.credential(verificationId: id, smsCode: smsCode);
      final user = (await _auth.signInWithCredential(cred)).user;
      if (user == null) return const Err('ورود ناموفق بود');
      final ref = _db.collection(CollectionPaths.users).doc(user.uid);
      final existing = await ref.get();
      if (!existing.exists) {
        final profile = UserProfile(
          id: user.uid,
          phone: phone,
          displayName: displayName?.trim().isNotEmpty == true ? displayName!.trim() : 'کاربر پولاد',
          createdAt: DateTime.now(),
        );
        await ref.set(profile.toMap());
        _cached = profile;
        return Ok(profile);
      }
      _cached = UserProfile.fromMap(_withDates({'id': existing.id, ...existing.data()!}));
      return Ok(_cached!);
    } on FirebaseAuthException catch (e) {
      return Err(e.message ?? 'کد تأیید نادرست است');
    }
  }

  @override
  Future<Result<void>> updateProfile({required String displayName, String? avatarUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return const Err('وارد نشده‌اید');
    await _db.collection(CollectionPaths.users).doc(user.uid).update({
      'displayName': displayName,
      'avatarUrl': ?avatarUrl,
    });
    _cached = _cached?.copyWith(displayName: displayName, avatarUrl: avatarUrl ?? _cached?.avatarUrl);
    return const Ok(null);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _toE164(String phone) {
    if (phone.startsWith('+')) return phone;
    if (phone.startsWith('09')) return '+98${phone.substring(1)}';
    return phone;
  }
}

class FirebaseCallable {
  FirebaseCallable(this._functions);
  final FirebaseFunctions _functions;

  Future<Result<Map<String, dynamic>>> call(String name, [Map<String, dynamic>? data]) async {
    try {
      final res = await _functions.httpsCallable(name).call(data ?? {});
      return Ok(Map<String, dynamic>.from(res.data as Map));
    } on FirebaseFunctionsException catch (e) {
      return Err(e.message ?? 'خطای سرور');
    }
  }
}
