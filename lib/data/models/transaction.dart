import 'package:freezed_annotation/freezed_annotation.dart';

import 'converters/iso_date_time_converter.dart';
import 'enums.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

/// تراکنش مالی صندوق.
///
/// تا وقتی وضعیت [TransactionStatus.pendingApproval] است در موجودی اعمال
/// نمی‌شود. [feeAmount] هزینه خدمات محاسبه‌شده برای صورتحساب مدیر است و
/// [feeApplied] نشان می‌دهد این مبلغ روی پرداخت عضو اعمال نشده است.
@freezed
abstract class Transaction with _$Transaction {
  /// سازندهٔ اصلی مدل تراکنش.
  const factory Transaction({
    /// شناسه سند تراکنش.
    required String transactionId,

    /// صندوق مربوطه.
    required String fundId,

    /// عضوی که تراکنش به او تعلق دارد.
    required String memberId,

    /// مبلغ به تومان. این همان مبلغی است که به صندوق می‌نشیند.
    required int amount,

    /// کد پیگیری کارت‌به‌کارت / بانکیما.
    String? receiptCode,

    /// تاریخ وقوع واریز یا برداشت از دید عضو.
    @IsoDateTimeConverter() required DateTime date,

    /// وضعیت تأیید مدیر.
    required TransactionStatus status,

    /// نوع عملیات مالی.
    required TransactionType type,

    /// نشانی تصویر فیش در Storage (اختیاری).
    String? receiptImageUrl,

    /// زمان ثبت در اپلیکیشن.
    @IsoDateTimeConverter() required DateTime submittedAt,

    /// uid مدیری که تصمیم گرفته است.
    String? approvedBy,

    /// زمان تأیید یا رد.
    @NullableIsoDateTimeConverter() DateTime? approvedAt,

    /// مبلغ هزینه خدمات نرم‌افزاری مربوط به این تراکنش (بدهی مدیر).
    @Default(0) int feeAmount,

    /// اگر `true` باشد یعنی هزینه در صورتحساب مدیر ثبت شده است، نه کسر از عضو.
    @Default(false) bool feeApplied,
  }) = _Transaction;

  /// ساخت مدل از JSON / Map فایراستور.
  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
