import 'package:equatable/equatable.dart';

import '../enums.dart';

class MoneyTransaction extends Equatable {
  const MoneyTransaction({
    required this.id,
    required this.fundId,
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.amount,
    required this.status,
    required this.occurredAt,
    required this.submittedAt,
    this.trackingCode,
    this.receiptUrl,
    this.reviewerId,
    this.reviewNote,
    this.relatedLoanId,
    this.relatedInstallmentId,
    this.source = PaymentSource.manual,
  });

  final String id;
  final String fundId;
  final String memberId;
  final String memberName;
  final TransactionType type;
  final int amount;
  final TransactionStatus status;
  final DateTime occurredAt;
  final DateTime submittedAt;
  final String? trackingCode;
  final String? receiptUrl;
  final String? reviewerId;
  final String? reviewNote;
  final String? relatedLoanId;
  final String? relatedInstallmentId;
  final PaymentSource source;

  Map<String, dynamic> toMap() => {
    'id': id,
    'fundId': fundId,
    'memberId': memberId,
    'memberName': memberName,
    'type': type.name,
    'amount': amount,
    'status': status.firestoreValue,
    'occurredAt': occurredAt.toIso8601String(),
    'submittedAt': submittedAt.toIso8601String(),
    'trackingCode': trackingCode,
    'receiptUrl': receiptUrl,
    'reviewerId': reviewerId,
    'reviewNote': reviewNote,
    'relatedLoanId': relatedLoanId,
    'relatedInstallmentId': relatedInstallmentId,
    'source': source.name,
  };

  factory MoneyTransaction.fromMap(Map<String, dynamic> map) => MoneyTransaction(
    id: map['id'] as String,
    fundId: map['fundId'] as String,
    memberId: map['memberId'] as String,
    memberName: map['memberName'] as String? ?? '',
    type: TransactionType.values.byName(map['type'] as String),
    amount: map['amount'] as int,
    status: TransactionStatusWire.fromWire(map['status']),
    occurredAt: DateTime.parse(map['occurredAt'] as String),
    submittedAt: DateTime.parse(map['submittedAt'] as String),
    trackingCode: map['trackingCode'] as String?,
    receiptUrl: map['receiptUrl'] as String?,
    reviewerId: map['reviewerId'] as String?,
    reviewNote: map['reviewNote'] as String?,
    relatedLoanId: map['relatedLoanId'] as String?,
    relatedInstallmentId: map['relatedInstallmentId'] as String?,
    source: PaymentSource.values.byName(map['source'] as String? ?? 'manual'),
  );

  MoneyTransaction copyWith({
    TransactionStatus? status,
    String? reviewerId,
    String? reviewNote,
    String? receiptUrl,
  }) {
    return MoneyTransaction(
      id: id,
      fundId: fundId,
      memberId: memberId,
      memberName: memberName,
      type: type,
      amount: amount,
      status: status ?? this.status,
      occurredAt: occurredAt,
      submittedAt: submittedAt,
      trackingCode: trackingCode,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewNote: reviewNote ?? this.reviewNote,
      relatedLoanId: relatedLoanId,
      relatedInstallmentId: relatedInstallmentId,
      source: source,
    );
  }

  @override
  List<Object?> get props => [id, status, amount, memberId, type];
}

class Loan extends Equatable {
  const Loan({
    required this.id,
    required this.fundId,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.termMonths,
    required this.reason,
    required this.status,
    required this.adminFeeRate,
    required this.requestedAt,
    this.decidedAt,
    this.decidedBy,
    this.decisionNote,
  });

  final String id;
  final String fundId;
  final String memberId;
  final String memberName;
  final int amount;
  final int termMonths;
  final String reason;
  final LoanStatus status;
  final double adminFeeRate;
  final DateTime requestedAt;
  final DateTime? decidedAt;
  final String? decidedBy;
  final String? decisionNote;

  Map<String, dynamic> toMap() => {
    'id': id,
    'fundId': fundId,
    'memberId': memberId,
    'memberName': memberName,
    'amount': amount,
    'termMonths': termMonths,
    'reason': reason,
    'status': status.name,
    'adminFeeRate': adminFeeRate,
    'requestedAt': requestedAt.toIso8601String(),
    'decidedAt': decidedAt?.toIso8601String(),
    'decidedBy': decidedBy,
    'decisionNote': decisionNote,
  };

  factory Loan.fromMap(Map<String, dynamic> map) => Loan(
    id: map['id'] as String,
    fundId: map['fundId'] as String,
    memberId: map['memberId'] as String,
    memberName: map['memberName'] as String? ?? '',
    amount: map['amount'] as int,
    termMonths: map['termMonths'] as int,
    reason: map['reason'] as String? ?? '',
    status: LoanStatus.values.byName(map['status'] as String),
    adminFeeRate: (map['adminFeeRate'] as num).toDouble(),
    requestedAt: DateTime.parse(map['requestedAt'] as String),
    decidedAt: map['decidedAt'] == null ? null : DateTime.parse(map['decidedAt'] as String),
    decidedBy: map['decidedBy'] as String?,
    decisionNote: map['decisionNote'] as String?,
  );

  Loan copyWith({LoanStatus? status, DateTime? decidedAt, String? decidedBy, String? decisionNote}) {
    return Loan(
      id: id,
      fundId: fundId,
      memberId: memberId,
      memberName: memberName,
      amount: amount,
      termMonths: termMonths,
      reason: reason,
      status: status ?? this.status,
      adminFeeRate: adminFeeRate,
      requestedAt: requestedAt,
      decidedAt: decidedAt ?? this.decidedAt,
      decidedBy: decidedBy ?? this.decidedBy,
      decisionNote: decisionNote ?? this.decisionNote,
    );
  }

  @override
  List<Object?> get props => [id, status, amount, memberId];
}

class Installment extends Equatable {
  const Installment({
    required this.id,
    required this.loanId,
    required this.fundId,
    required this.memberId,
    required this.sequence,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidTransactionId,
    this.principalPart = 0,
    this.feePart = 0,
  });

  final String id;
  final String loanId;
  final String fundId;
  final String memberId;
  final int sequence;
  final int amount;
  final DateTime dueDate;
  final InstallmentStatus status;
  final String? paidTransactionId;
  final int principalPart;
  final int feePart;

  Map<String, dynamic> toMap() => {
    'id': id,
    'loanId': loanId,
    'fundId': fundId,
    'memberId': memberId,
    'sequence': sequence,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'status': status.name,
    'paidTransactionId': paidTransactionId,
    'principalPart': principalPart,
    'feePart': feePart,
  };

  factory Installment.fromMap(Map<String, dynamic> map) => Installment(
    id: map['id'] as String,
    loanId: map['loanId'] as String,
    fundId: map['fundId'] as String,
    memberId: map['memberId'] as String,
    sequence: map['sequence'] as int,
    amount: map['amount'] as int,
    dueDate: DateTime.parse(map['dueDate'] as String),
    status: InstallmentStatus.values.byName(map['status'] as String),
    paidTransactionId: map['paidTransactionId'] as String?,
    principalPart: map['principalPart'] as int? ?? 0,
    feePart: map['feePart'] as int? ?? 0,
  );

  Installment copyWith({InstallmentStatus? status, String? paidTransactionId}) {
    return Installment(
      id: id,
      loanId: loanId,
      fundId: fundId,
      memberId: memberId,
      sequence: sequence,
      amount: amount,
      dueDate: dueDate,
      status: status ?? this.status,
      paidTransactionId: paidTransactionId ?? this.paidTransactionId,
      principalPart: principalPart,
      feePart: feePart,
    );
  }

  @override
  List<Object?> get props => [id, status, amount, dueDate];
}

class FundDraw extends Equatable {
  const FundDraw({
    required this.id,
    required this.fundId,
    required this.title,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.mode,
    this.winnerMemberId,
    this.winnerName,
    this.prizeAmount = 0,
    this.eligibleMemberIds = const [],
  });

  final String id;
  final String fundId;
  final String title;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DrawStatus status;
  final DrawSelectionMode mode;
  final String? winnerMemberId;
  final String? winnerName;
  final int prizeAmount;
  final List<String> eligibleMemberIds;

  Map<String, dynamic> toMap() => {
    'id': id,
    'fundId': fundId,
    'title': title,
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'status': status.name,
    'mode': mode.name,
    'winnerMemberId': winnerMemberId,
    'winnerName': winnerName,
    'prizeAmount': prizeAmount,
    'eligibleMemberIds': eligibleMemberIds,
  };

  factory FundDraw.fromMap(Map<String, dynamic> map) => FundDraw(
    id: map['id'] as String,
    fundId: map['fundId'] as String,
    title: map['title'] as String,
    periodStart: DateTime.parse(map['periodStart'] as String),
    periodEnd: DateTime.parse(map['periodEnd'] as String),
    status: DrawStatus.values.byName(map['status'] as String),
    mode: DrawSelectionMode.values.byName(map['mode'] as String),
    winnerMemberId: map['winnerMemberId'] as String?,
    winnerName: map['winnerName'] as String?,
    prizeAmount: map['prizeAmount'] as int? ?? 0,
    eligibleMemberIds: (map['eligibleMemberIds'] as List?)?.cast<String>() ?? const [],
  );

  FundDraw copyWith({
    DrawStatus? status,
    String? winnerMemberId,
    String? winnerName,
    DrawSelectionMode? mode,
  }) {
    return FundDraw(
      id: id,
      fundId: fundId,
      title: title,
      periodStart: periodStart,
      periodEnd: periodEnd,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      winnerMemberId: winnerMemberId ?? this.winnerMemberId,
      winnerName: winnerName ?? this.winnerName,
      prizeAmount: prizeAmount,
      eligibleMemberIds: eligibleMemberIds,
    );
  }

  @override
  List<Object?> get props => [id, status, winnerMemberId, title];
}

class ServiceInvoice extends Equatable {
  const ServiceInvoice({
    required this.id,
    required this.fundId,
    required this.adminId,
    required this.year,
    required this.month,
    required this.transactionVolume,
    required this.feeAmount,
    required this.status,
    required this.rate,
    this.note =
        'هزینه خدمات نرم‌افزاری پولاد — طبق بخشنامه شاپرک از عضو کسر نمی‌شود و فقط از مدیر صندوق دریافت می‌گردد.',
  });

  final String id;
  final String fundId;
  final String adminId;
  final int year;
  final int month;
  final int transactionVolume;
  final int feeAmount;
  final InvoiceStatus status;
  final double rate;
  final String note;

  Map<String, dynamic> toMap() => {
    'id': id,
    'fundId': fundId,
    'adminId': adminId,
    'year': year,
    'month': month,
    'transactionVolume': transactionVolume,
    'feeAmount': feeAmount,
    'status': status.name,
    'rate': rate,
    'note': note,
  };

  factory ServiceInvoice.fromMap(Map<String, dynamic> map) => ServiceInvoice(
    id: map['id'] as String,
    fundId: map['fundId'] as String,
    adminId: map['adminId'] as String,
    year: map['year'] as int,
    month: map['month'] as int,
    transactionVolume: map['transactionVolume'] as int,
    feeAmount: map['feeAmount'] as int,
    status: InvoiceStatus.values.byName(map['status'] as String),
    rate: (map['rate'] as num).toDouble(),
    note: map['note'] as String? ?? '',
  );

  @override
  List<Object?> get props => [id, status, feeAmount, year, month];
}

class CashflowPoint extends Equatable {
  const CashflowPoint({required this.label, required this.inflow, required this.outflow});
  final String label;
  final int inflow;
  final int outflow;
  @override
  List<Object?> get props => [label, inflow, outflow];
}

class FundReport extends Equatable {
  const FundReport({
    required this.balance,
    required this.totalIn,
    required this.totalOut,
    required this.overdueCount,
    required this.overdueAmount,
    required this.points,
    this.softwareFeeToAdmin = 0,
    this.serviceFeeRate = 0.005,
    this.charityZeroFee = false,
  });

  final int balance;
  final int totalIn;
  final int totalOut;
  final int overdueCount;
  final int overdueAmount;
  final List<CashflowPoint> points;

  /// هزینه خدمات نرم‌افزاری همان ماه/دوره — بدهی مدیر، نه کسر از اعضا.
  final int softwareFeeToAdmin;
  final double serviceFeeRate;
  final bool charityZeroFee;

  int get net => totalIn - totalOut;

  @override
  List<Object?> get props => [balance, totalIn, totalOut, overdueCount, softwareFeeToAdmin, charityZeroFee];
}

class BankSms extends Equatable {
  const BankSms({
    required this.sender,
    required this.body,
    required this.receivedAt,
    this.amount,
    this.trackingCode,
    this.isCredit,
    this.bank = IranianBank.unknown,
    this.occurredAt,
    this.rawDate,
  });

  final String sender;
  final String body;
  final DateTime receivedAt;

  /// مبلغ به تومان. اگر پیامک ریال باشد تبدیل شده است.
  final int? amount;
  final String? trackingCode;
  final bool? isCredit;
  final IranianBank bank;

  /// تاریخ استخراج‌شده از متن پیامک (شمسی یا میلادی).
  final DateTime? occurredAt;
  final String? rawDate;

  bool get isParseable => amount != null && (trackingCode?.isNotEmpty ?? false);

  @override
  List<Object?> get props => [sender, body, receivedAt, amount, trackingCode, bank];
}
