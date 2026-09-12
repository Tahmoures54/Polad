import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/iso_date_time_converter.dart';
import 'enums.dart';

part 'loan.freezed.dart';
part 'loan.g.dart';

/// درخواست و پرونده وام قرض‌الحسنه.
///
/// [feeRate] هزینه اداری صندوق روی اقساط است (مثلاً ۲٪) و بهره بانکی نیست.
@freezed
abstract class Loan with _$Loan {
  /// سازندهٔ اصلی مدل وام.
  const factory Loan({
    /// شناسه سند وام.
    required String loanId,

    /// صندوق پرداخت‌کننده.
    required String fundId,

    /// عضو درخواست‌کننده.
    required String memberId,

    /// مبلغ اصل وام به تومان.
    required int amount,

    /// تعداد اقساط بازپرداخت.
    required int installmentsCount,

    /// وضعیت پرونده وام.
    required LoanStatus status,

    /// نرخ هزینه اداری صندوق، مثلاً `0.02`.
    required double feeRate,

    /// زمان ثبت درخواست.
    @IsoDateTimeConverter() required DateTime createdAt,
  }) = _Loan;

  /// ساخت مدل از JSON / Map فایراستور.
  factory Loan.fromJson(Map<String, dynamic> json) => _$LoanFromJson(json);
}
