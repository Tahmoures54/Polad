import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/iso_date_time_converter.dart';
import 'enums.dart';

part 'fee.freezed.dart';
part 'fee.g.dart';

/// صورتحساب هزینه خدمات نرم‌افزاری پولاد برای مدیر صندوق.
///
/// طبق بخشنامه شاپرک این مبلغ از تراکنش عضو کسر نمی‌شود و فقط بدهی مدیر است.
@freezed
abstract class Fee with _$Fee {
  /// سازندهٔ اصلی مدل هزینه خدمات.
  const factory Fee({
    /// شناسه سند صورتحساب.
    required String feeId,

    /// صندوق مشمول.
    required String fundId,

    /// کلید ماه دوره، ترجیحاً شمسی مثل `1404-06`.
    required String month,

    /// جمع هزینه خدمات آن ماه به تومان.
    required int totalAmount,

    /// وضعیت تسویه توسط مدیر.
    required FeeStatus status,

    /// زمان پرداخت صورتحساب — فقط وقتی [status] برابر paid است.
    @NullableIsoDateTimeConverter() DateTime? paidAt,
  }) = _Fee;

  /// ساخت مدل از JSON / Map فایراستور.
  factory Fee.fromJson(Map<String, dynamic> json) => _$FeeFromJson(json);
}
