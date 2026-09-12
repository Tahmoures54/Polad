import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/app_result.dart';
import '../../core/error/failure.dart';
import '../../core/network/guard.dart';
import '../../core/network/network_retry.dart';

/// نتیجه آپلود فیش در Storage.
class StoredFile {
  const StoredFile({required this.path, required this.downloadUrl});

  /// مسیر داخل باکت (برای حذف بعدی).
  final String path;

  /// نشانی قابل‌نمایش در اپ و ذخیره در تراکنش.
  final String downloadUrl;
}

/// آپلود تصویر فیش و حذف فایل از Firebase Storage.
abstract class StorageService {
  /// آپلود تصویر فیش پرداخت به `receipts/{fundId}/{file}`.
  Future<AppResult<StoredFile>> uploadReceipt({
    required File file,
    required String fundId,
    String? transactionId,
  });

  /// حذف فایل با مسیر نسبی داخل باکت.
  Future<AppResult<Unit>> deleteFile(String path);

  /// حذف فایل با URL دانلود (اگر parse شود).
  Future<AppResult<Unit>> deleteByUrl(String downloadUrl);
}

/// پیاده‌سازی Firebase Storage با retry برای خطاهای شبکه.
class FirebaseStorageService implements StorageService {
  FirebaseStorageService(this._storage, {NetworkRetry? retry})
      : _retry = retry ?? NetworkRetry.standard;

  final FirebaseStorage _storage;
  final NetworkRetry _retry;
  final _uuid = const Uuid();

  @override
  Future<AppResult<StoredFile>> uploadReceipt({
    required File file,
    required String fundId,
    String? transactionId,
  }) {
    return guardNetwork(() async {
      if (!file.existsSync()) {
        throw const NotFoundFailure(message: 'فایل فیش روی دستگاه پیدا نشد');
      }
      final name = '${transactionId ?? _uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = '${CollectionPaths.receiptsPrefix}/$fundId/$name';
      final ref = _storage.ref(path);
      await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg', cacheControl: 'private, max-age=86400'),
      );
      final url = await ref.getDownloadURL();
      return StoredFile(path: path, downloadUrl: url);
    }, retry: _retry);
  }

  @override
  Future<AppResult<Unit>> deleteFile(String path) {
    return guardNetwork(() async {
      await _storage.ref(path).delete();
      return unit;
    }, retry: _retry);
  }

  @override
  Future<AppResult<Unit>> deleteByUrl(String downloadUrl) {
    return guardNetwork(() async {
      await _storage.refFromURL(downloadUrl).delete();
      return unit;
    }, retry: _retry);
  }
}

/// حالت دمو: بدون آپلود واقعی؛ URL ساختگی برمی‌گردد.
class DemoStorageService implements StorageService {
  final deleted = <String>[];

  @override
  Future<AppResult<StoredFile>> uploadReceipt({
    required File file,
    required String fundId,
    String? transactionId,
  }) async {
    final path = '${CollectionPaths.receiptsPrefix}/$fundId/${transactionId ?? 'demo'}.jpg';
    return right(StoredFile(path: path, downloadUrl: 'demo://$path'));
  }

  @override
  Future<AppResult<Unit>> deleteFile(String path) async {
    deleted.add(path);
    return right(unit);
  }

  @override
  Future<AppResult<Unit>> deleteByUrl(String downloadUrl) async {
    deleted.add(downloadUrl);
    return right(unit);
  }
}
