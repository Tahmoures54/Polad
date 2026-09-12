import 'package:equatable/equatable.dart';

import '../../core/utils/formatters.dart';
import '../../domain/enums.dart';

/// بازهٔ تاریخ برای گردش حساب.
class DateRange extends Equatable {
  const DateRange({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  bool get isValid => !from.isAfter(to);

  @override
  List<Object?> get props => [from, to];
}

/// نتیجهٔ استعلام تراکنش با کد رسید / پیگیری.
class BankimaVerifiedTx extends Equatable {
  const BankimaVerifiedTx({
    required this.receiptCode,
    required this.amountToman,
    required this.occurredAt,
    required this.status,
    this.iban,
    this.description,
    this.raw = const {},
  });

  final String receiptCode;
  final int amountToman;
  final DateTime occurredAt;

  /// وضعیت بانکی (مثلاً `settled`) — تأیید صندوق جدا و فقط با مدیر است.
  final String status;
  final String? iban;
  final String? description;
  final Map<String, dynamic> raw;

  bool get isSettled => status == 'settled' || status == 'success' || status == 'verified';

  factory BankimaVerifiedTx.fromJson(Map<String, dynamic> json, {String? fallbackCode}) {
    return BankimaVerifiedTx(
      receiptCode: json['receiptCode'] as String? ?? json['trackingCode'] as String? ?? fallbackCode ?? '',
      amountToman: _amountToman(json),
      occurredAt: DateTime.tryParse(json['occurredAt'] as String? ?? json['date'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? 'unknown',
      iban: json['iban'] as String?,
      description: json['description'] as String?,
      raw: json,
    );
  }

  @override
  List<Object?> get props => [receiptCode, amountToman, status];
}

/// یک ردیف گردش حساب.
class BankimaStatementRow extends Equatable {
  const BankimaStatementRow({
    required this.amountToman,
    required this.trackingCode,
    required this.isCredit,
    required this.occurredAt,
    this.description = '',
  });

  final int amountToman;
  final String trackingCode;
  final bool isCredit;
  final DateTime occurredAt;
  final String description;

  factory BankimaStatementRow.fromJson(Map<String, dynamic> json) {
    return BankimaStatementRow(
      amountToman: _amountToman(json),
      trackingCode: json['trackingCode'] as String? ?? json['receiptCode'] as String? ?? '',
      isCredit: json['isCredit'] as bool? ?? (json['direction'] as String?) == 'credit',
      occurredAt: DateTime.tryParse(json['occurredAt'] as String? ?? '') ?? DateTime.now(),
      description: json['description'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [trackingCode, amountToman, isCredit, occurredAt];
}

class BankimaStatement extends Equatable {
  const BankimaStatement({
    required this.accountId,
    required this.range,
    required this.rows,
  });

  final String accountId;
  final DateRange range;
  final List<BankimaStatementRow> rows;

  @override
  List<Object?> get props => [accountId, range, rows];
}

class BankimaBalance extends Equatable {
  const BankimaBalance({
    required this.accountId,
    required this.availableToman,
    this.blockedToman = 0,
    this.currency = 'IRR',
    this.asOf,
  });

  final String accountId;
  final int availableToman;
  final int blockedToman;
  final String currency;
  final DateTime? asOf;

  factory BankimaBalance.fromJson(String accountId, Map<String, dynamic> json) {
    return BankimaBalance(
      accountId: accountId,
      availableToman: _amountToman(json, keys: const ['availableToman', 'availableRial', 'balanceRial', 'amountRial']),
      blockedToman: _amountToman(json, keys: const ['blockedToman', 'blockedRial']),
      currency: json['currency'] as String? ?? 'IRR',
      asOf: DateTime.tryParse(json['asOf'] as String? ?? ''),
    );
  }

  @override
  List<Object?> get props => [accountId, availableToman, blockedToman];
}

/// اطلاعات اقساط تسهیلات سمت بانکیما (متفاوت از جدول اقساط داخلی صندوق).
class BankimaInstallmentInfo extends Equatable {
  const BankimaInstallmentInfo({
    required this.loanId,
    required this.principalToman,
    required this.remainingToman,
    required this.installments,
  });

  final String loanId;
  final int principalToman;
  final int remainingToman;
  final List<BankimaInstallmentRow> installments;

  factory BankimaInstallmentInfo.fromJson(String loanId, Map<String, dynamic> json) {
    final items = (json['installments'] as List? ?? json['items'] as List? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .map(BankimaInstallmentRow.fromJson)
        .toList();
    return BankimaInstallmentInfo(
      loanId: loanId,
      principalToman: _amountToman(json, keys: const ['principalToman', 'principalRial', 'amountRial']),
      remainingToman: _amountToman(json, keys: const ['remainingToman', 'remainingRial']),
      installments: items,
    );
  }

  @override
  List<Object?> get props => [loanId, principalToman, remainingToman, installments];
}

class BankimaInstallmentRow extends Equatable {
  const BankimaInstallmentRow({
    required this.sequence,
    required this.amountToman,
    required this.dueDate,
    required this.paid,
  });

  final int sequence;
  final int amountToman;
  final DateTime dueDate;
  final bool paid;

  factory BankimaInstallmentRow.fromJson(Map<String, dynamic> json) {
    return BankimaInstallmentRow(
      sequence: json['sequence'] as int? ?? json['number'] as int? ?? 0,
      amountToman: _amountToman(json),
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      paid: json['paid'] as bool? ?? json['status'] == 'paid',
    );
  }

  @override
  List<Object?> get props => [sequence, amountToman, paid];
}

class BankimaPaymentLink extends Equatable {
  const BankimaPaymentLink({
    required this.orderId,
    required this.url,
    required this.memberId,
    required this.amountToman,
    this.expiresAt,
  });

  final String orderId;
  final String url;
  final String memberId;
  final int amountToman;
  final DateTime? expiresAt;

  factory BankimaPaymentLink.fromJson(Map<String, dynamic> json) {
    return BankimaPaymentLink(
      orderId: json['orderId'] as String? ?? json['id'] as String? ?? '',
      url: json['redirectUrl'] as String? ?? json['url'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      amountToman: _amountToman(json, keys: const ['amountToman', 'amountRial']),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? ''),
    );
  }

  @override
  List<Object?> get props => [orderId, url, memberId, amountToman];
}

class BankimaTransferResult extends Equatable {
  const BankimaTransferResult({
    required this.rail,
    required this.paymentId,
    required this.trackId,
    required this.amountToman,
    required this.status,
    this.destinationIban,
  });

  final BankTransferRail rail;
  final String paymentId;
  final String trackId;
  final int amountToman;
  final String status;
  final String? destinationIban;

  factory BankimaTransferResult.fromJson(Map<String, dynamic> json, BankTransferRail rail) {
    return BankimaTransferResult(
      rail: rail,
      paymentId: json['paymentId'] as String? ?? json['id'] as String? ?? '',
      trackId: json['trackId'] as String? ?? json['trackingCode'] as String? ?? '',
      amountToman: _amountToman(json, keys: const ['amountToman', 'amountRial']),
      status: json['status'] as String? ?? 'submitted',
      destinationIban: json['destinationIban'] as String?,
    );
  }

  @override
  List<Object?> get props => [rail, paymentId, trackId, status];
}

int _amountToman(Map<String, dynamic> json, {List<String> keys = const ['amountToman', 'amountRial', 'amount']}) {
  for (final key in keys) {
    final v = json[key];
    if (v is num) {
      if (key.toLowerCase().contains('rial')) return rialToToman(v.toInt());
      return v.toInt();
    }
  }
  return 0;
}
