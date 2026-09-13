import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// مبدل تاریخ برای Freezed / json_serializable.
///
/// خواندن از JSON رشته‌ای، میلی‌ثانیه، [DateTime] یا [Timestamp] فایراستور را
/// می‌پذیرد تا هم کش محلی و هم اسناد زنده بدون تبدیل دستی کار کنند.
/// نوشتن در JSON همیشه با ISO-8601 انجام می‌شود؛ تبدیل به Timestamp در
/// لایهٔ Firestore انجام می‌گیرد.
class IsoDateTimeConverter implements JsonConverter<DateTime, dynamic> {
  /// سازنده ثابت برای استفاده در `@IsoDateTimeConverter()`.
  const IsoDateTimeConverter();

  @override
  DateTime fromJson(dynamic json) {
    if (json is DateTime) return json;
    if (json is Timestamp) return json.toDate();
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    if (json is String && json.isNotEmpty) return DateTime.parse(json);
    throw FormatException('مقدار تاریخ نامعتبر است: $json');
  }

  @override
  String toJson(DateTime object) => object.toUtc().toIso8601String();
}

/// نسخهٔ قابل‌تهی [IsoDateTimeConverter] برای فیلدهای اختیاری مثل زمان تأیید.
class NullableIsoDateTimeConverter implements JsonConverter<DateTime?, dynamic> {
  /// سازنده ثابت برای استفاده در `@NullableIsoDateTimeConverter()`.
  const NullableIsoDateTimeConverter();

  @override
  DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    return const IsoDateTimeConverter().fromJson(json);
  }

  @override
  String? toJson(DateTime? object) =>
      object == null ? null : const IsoDateTimeConverter().toJson(object);
}
