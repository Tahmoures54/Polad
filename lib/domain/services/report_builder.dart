import 'package:shamsi_date/shamsi_date.dart';

import '../../core/utils/formatters.dart';
import '../entities/finance.dart';
import '../entities/people.dart';
import '../entities/reports.dart';
import '../enums.dart';
import 'finance_services.dart';

/// ساخت گزارش صندوق از داده‌های دامنه — بدون IO تا تست‌پذیر باشد.
class ReportBuilder {
  const ReportBuilder();

  PoladReport build({
    required Fund fund,
    required List<MoneyTransaction> transactions,
    required List<Installment> installments,
    required List<Loan> loans,
    required List<FundMember> members,
    required List<ServiceInvoice> invoices,
    ReportFilter filter = const ReportFilter(),
  }) {
    final txs = transactions.where((t) => _matchTx(t, filter)).toList();
    final approved = txs.where((t) => t.status == TransactionStatus.approved);
    final overdue = installments.where((i) {
      if (i.status != InstallmentStatus.overdue) return false;
      if (filter.memberId != null && i.memberId != filter.memberId) return false;
      return true;
    }).toList();

    final grouped = <String, CashflowPoint>{};
    for (final t in approved) {
      final label = _monthLabel(t.occurredAt);
      final prev = grouped[label] ?? CashflowPoint(label: label, inflow: 0, outflow: 0);
      final isOut = t.type == TransactionType.loanDisbursement || t.type == TransactionType.withdrawal;
      grouped[label] = CashflowPoint(
        label: label,
        inflow: prev.inflow + (isOut ? 0 : t.amount),
        outflow: prev.outflow + (isOut ? t.amount : 0),
      );
    }
    final points = grouped.values.toList()..sort((a, b) => a.label.compareTo(b.label));

    final inSum = approved
        .where((t) => t.type != TransactionType.loanDisbursement && t.type != TransactionType.withdrawal)
        .fold<int>(0, (a, b) => a + b.amount);
    final outSum = approved
        .where((t) => t.type == TransactionType.loanDisbursement || t.type == TransactionType.withdrawal)
        .fold<int>(0, (a, b) => a + b.amount);

    final fee = const FeeCalculator().accrue(
      approved.map((t) => t.amount),
      fund.serviceFeeRate,
      charityZeroFee: fund.isCharity,
    );

    final loanSlices = [
      for (final status in LoanStatus.values)
        LoanSlice(
          status: status,
          count: loans.where((l) => l.status == status).length,
          amount: loans.where((l) => l.status == status).fold<int>(0, (a, b) => a + b.amount),
        ),
    ].where((s) => s.count > 0).toList();

    final memberRows = members.map((m) {
      final mine = installments.where((i) => i.memberId == m.userId);
      final paid = txs.where((t) => t.memberId == m.userId && t.status == TransactionStatus.approved);
      return MemberPerformance(
        member: m,
        paidCount: paid.length,
        overdueCount: mine.where((i) => i.status == InstallmentStatus.overdue).length,
        paidAmount: paid.fold(0, (a, b) => a + b.amount),
      );
    }).toList()
      ..sort((a, b) => b.paidAmount.compareTo(a.paidAmount));

    final feePoints = invoices.map((i) {
      return MonthlyFeePoint(
        label: '${faDigits(i.year)}/${faDigits(i.month.toString().padLeft(2, '0'))}',
        feeAmount: i.feeAmount,
        volume: i.transactionVolume,
      );
    }).toList()
      ..sort((a, b) => a.label.compareTo(b.label));

    return PoladReport(
      summary: FundReport(
        balance: fund.balance,
        totalIn: inSum,
        totalOut: outSum,
        overdueCount: overdue.length,
        overdueAmount: overdue.fold(0, (a, b) => a + b.amount),
        points: points,
        softwareFeeToAdmin: fee,
        serviceFeeRate: fund.serviceFeeRate,
        charityZeroFee: fund.isCharity,
      ),
      loanSlices: loanSlices,
      members: memberRows,
      feePoints: feePoints,
      overdue: overdue,
      filteredTransactions: txs,
    );
  }

  bool _matchTx(MoneyTransaction t, ReportFilter filter) {
    if (filter.memberId != null && t.memberId != filter.memberId) return false;
    if (filter.type != null && t.type != filter.type) return false;
    if (filter.from != null && t.occurredAt.isBefore(filter.from!)) return false;
    if (filter.to != null && t.occurredAt.isAfter(filter.to!)) return false;
    return true;
  }

  String _monthLabel(DateTime date) {
    final j = Jalali.fromDateTime(date);
    return '${j.year}/${j.month.toString().padLeft(2, '0')}';
  }
}
