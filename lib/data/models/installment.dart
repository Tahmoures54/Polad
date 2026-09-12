import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/iso_date_time_converter.dart';
import 'enums.dart';

part 'installment.freezed.dart';
part 'installment.g.dart';

/// یک قسط از جدول بازپرداخت وام.
@freezed
abstract class Installment with _$Installment {
  /// سازندهٔ اصلی مدل قسط.
  const factory Installment({
    /// شناسه سند قسط.
    required String installmentId,

    /// وام والد.
    required String loanId,

    /// عضو بدهکار.
    required String memberId,

    /// مبلغ این قسط به تومان.
    required int amount,

    /// تاریخ سررسید.
    @IsoDateTimeConverter() required DateTime dueDate,

    /// وضعیت پرداخت نسبت به سررسید.
    required InstallmentStatus status,
  }) = _Installment;

  /// ساخت مدل از JSON / Map فایراستور.
  factory Installment.fromJson(Map<String, dynamic> json) =>
      _$InstallmentFromJson(json);
}
