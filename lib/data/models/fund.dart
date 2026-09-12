import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/iso_date_time_converter.dart';
import 'enums.dart';

part 'fund.freezed.dart';
part 'fund.g.dart';

/// صندوق قرض‌الحسنه خانوادگی.
///
/// [ownerId] همان مدیر اولیه است. [feeRate] نرخ هزینه خدمات نرم‌افزاری است
/// که فقط از مدیر دریافت می‌شود (۰٫۵٪ تا ۱٪) و از تراکنش عضو کسر نمی‌گردد.
@freezed
abstract class Fund with _$Fund {
  /// سازندهٔ اصلی مدل صندوق.
  const factory Fund({
    /// شناسه سند صندوق در Firestore.
    required String fundId,

    /// نام قابل‌نمایش صندوق برای اعضا.
    required String name,

    /// uid مدیر/مالک صندوق.
    required String ownerId,

    /// مبلغ سهم دوره‌ای به تومان.
    required int shareAmount,

    /// نوع دوره پرداخت سهم.
    required FundPeriodType periodType,

    /// نرخ هزینه خدمات نرم‌افزاری مدیر، مثلاً `0.005` برای ۰٫۵٪.
    required double feeRate,

    /// زمان ایجاد صندوق.
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _Fund;

  /// ساخت مدل از JSON / Map فایراستور.
  factory Fund.fromJson(Map<String, dynamic> json) => _$FundFromJson(json);
}
