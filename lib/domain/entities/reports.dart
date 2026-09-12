import 'package:equatable/equatable.dart';

import '../enums.dart';
import 'finance.dart';
import 'people.dart';

/// فیلترهای صفحهٔ گزارش مدیر.
class ReportFilter extends Equatable {
  const ReportFilter({this.from, this.to, this.memberId, this.type});

  final DateTime? from;
  final DateTime? to;
  final String? memberId;
  final TransactionType? type;

  ReportFilter copyWith({
    DateTime? from,
    DateTime? to,
    String? memberId,
    TransactionType? type,
    bool clearMember = false,
    bool clearType = false,
    bool clearDates = false,
  }) {
    return ReportFilter(
      from: clearDates ? null : (from ?? this.from),
      to: clearDates ? null : (to ?? this.to),
      memberId: clearMember ? null : (memberId ?? this.memberId),
      type: clearType ? null : (type ?? this.type),
    );
  }

  @override
  List<Object?> get props => [from, to, memberId, type];
}

class LoanSlice extends Equatable {
  const LoanSlice({required this.status, required this.count, required this.amount});
  final LoanStatus status;
  final int count;
  final int amount;
  @override
  List<Object?> get props => [status, count, amount];
}

class MemberPerformance extends Equatable {
  const MemberPerformance({
    required this.member,
    required this.paidCount,
    required this.overdueCount,
    required this.paidAmount,
  });

  final FundMember member;
  final int paidCount;
  final int overdueCount;
  final int paidAmount;

  @override
  List<Object?> get props => [member.userId, paidCount, overdueCount, paidAmount];
}

class MonthlyFeePoint extends Equatable {
  const MonthlyFeePoint({required this.label, required this.feeAmount, required this.volume});
  final String label;
  final int feeAmount;
  final int volume;
  @override
  List<Object?> get props => [label, feeAmount, volume];
}

/// گزارش کامل مدیر: جریان نقدی، وام، معوقات، کارمزد، عملکرد اعضا.
class PoladReport extends Equatable {
  const PoladReport({
    required this.summary,
    required this.loanSlices,
    required this.members,
    required this.feePoints,
    required this.overdue,
    required this.filteredTransactions,
  });

  final FundReport summary;
  final List<LoanSlice> loanSlices;
  final List<MemberPerformance> members;
  final List<MonthlyFeePoint> feePoints;
  final List<Installment> overdue;
  final List<MoneyTransaction> filteredTransactions;

  @override
  List<Object?> get props => [summary, loanSlices, members, feePoints, overdue];
}
