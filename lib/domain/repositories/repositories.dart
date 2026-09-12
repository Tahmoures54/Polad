import '../../core/utils/result.dart';
import '../entities/finance.dart';
import '../entities/people.dart';
import '../enums.dart';

class CreateFundInput {
  const CreateFundInput({
    required this.name,
    required this.shareAmount,
    required this.paymentPeriodDays,
    required this.serviceFeeRate,
    this.charterText,
    this.bankIban,
    this.bankAccount,
    this.isCharity = false,
  });

  final String name;
  final int shareAmount;
  final int paymentPeriodDays;
  final double serviceFeeRate;
  final String? charterText;
  final String? bankIban;
  final String? bankAccount;
  final bool isCharity;
}

class SubmitPaymentInput {
  const SubmitPaymentInput({
    required this.amount,
    required this.occurredAt,
    required this.trackingCode,
    required this.type,
    this.receiptPath,
    this.relatedInstallmentId,
    this.relatedLoanId,
  });

  final int amount;
  final DateTime occurredAt;
  final String trackingCode;
  final TransactionType type;
  final String? receiptPath;
  final String? relatedInstallmentId;
  final String? relatedLoanId;
}

abstract class AuthRepository {
  Stream<UserProfile?> authState();
  Future<Result<void>> sendOtp(String phone);
  Future<Result<UserProfile>> verifyOtp({required String phone, required String smsCode, String? displayName});
  Future<Result<void>> updateProfile({required String displayName});
  Future<void> signOut();
  UserProfile? get currentUser;
}

abstract class FundRepository {
  Stream<Fund?> watchFund(String fundId);
  Stream<List<FundMember>> watchMembers(String fundId);
  Future<Result<Fund>> createFund(CreateFundInput input);
  Future<Result<Fund>> joinByInvite(String code);
  Future<Result<void>> updateFund(Fund fund);
  Future<Result<void>> removeMember(String fundId, String userId);
  Future<Result<void>> changeRole(String fundId, String userId, UserRole role);
  Future<List<Fund>> myFunds();
  Future<Result<void>> setActiveFund(String fundId);
  Future<String> inviteLink(Fund fund);
}

abstract class TransactionRepository {
  Stream<List<MoneyTransaction>> watchForFund(String fundId);
  Stream<List<MoneyTransaction>> watchForMember(String fundId, String userId);
  Future<Result<MoneyTransaction>> submit(SubmitPaymentInput input);
  Future<Result<void>> approve(String transactionId, {String? note});
  Future<Result<void>> reject(String transactionId, {required String note});
}

abstract class LoanRepository {
  Stream<List<Loan>> watchLoans(String fundId);
  Stream<List<Installment>> watchInstallments(String fundId, {String? memberId});
  Future<Result<Loan>> requestLoan({required int amount, required int termMonths, required String reason});
  Future<Result<void>> decide({required String loanId, required bool approve, String? note});
}

abstract class DrawRepository {
  Stream<List<FundDraw>> watch(String fundId);
  Future<Result<FundDraw>> create({
    required String title,
    required DateTime start,
    required DateTime end,
    required int prizeAmount,
    required DrawSelectionMode mode,
  });
  Future<Result<FundDraw>> run({required String drawId, String? manualWinnerId});
}

abstract class BillingRepository {
  Stream<List<ServiceInvoice>> watch(String fundId);
  Future<Result<void>> markPaid(String invoiceId);
}

abstract class ReportRepository {
  Future<FundReport> build(String fundId);
  Future<Result<String>> exportExcel(String fundId);
  Future<Result<String>> exportPdf(String fundId);
}

abstract class SmsInbox {
  Future<bool> requestPermission();
  Future<List<BankSms>> readRecent({Duration window = const Duration(days: 7)});
}

abstract class PaymentGateway {
  Future<Result<String>> startSoftwareFeePayment({required String invoiceId, required int amountToman});
  Future<Result<void>> verify(String orderId);
}
