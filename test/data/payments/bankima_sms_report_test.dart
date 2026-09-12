import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polad/core/error/app_result.dart';
import 'package:polad/core/network/network_retry.dart';
import 'package:polad/data/payments/bankima_models.dart';
import 'package:polad/data/payments/bankima_service.dart';
import 'package:polad/data/sms/bank_sms_parser.dart';
import 'package:polad/data/sms/demo_sms_inbox.dart';
import 'package:polad/data/sms/sms_parser_service.dart';
import 'package:polad/domain/entities/finance.dart';
import 'package:polad/domain/entities/people.dart';
import 'package:polad/domain/enums.dart';
import 'package:polad/domain/repositories/repositories.dart';
import 'package:polad/core/utils/result.dart';
import 'package:polad/domain/services/report_builder.dart';

void main() {
  group('BankimaService demo', () {
    final svc = DemoBankimaService();

    test('verifyTransaction, statement, installments, link, balance, rails', () async {
      final tx = await svc.verifyTransaction('1403123456');
      expect(tx.isRight(), isTrue);
      expect(tx.valueOrNull!.isSettled, isTrue);

      final st = await svc.getAccountStatement('acc', DateRange(from: DateTime(2026, 1, 1), to: DateTime(2026, 9, 1)));
      expect(st.valueOrNull!.rows, isNotEmpty);

      final inst = await svc.getInstallmentInfo('loan-1');
      expect(inst.valueOrNull!.installments, isNotEmpty);

      final link = await svc.createPaymentLink('user-1', 5000000);
      expect(link.valueOrNull!.url, contains('bankima'));

      final bal = await svc.getBalance('acc');
      expect(bal.valueOrNull!.availableToman, greaterThan(0));

      for (final rail in BankTransferRail.values) {
        final t = await svc.transfer(
          rail: rail,
          destinationIban: 'IR120120000000000000000001',
          amountToman: 1000000,
          description: 'test',
        );
        expect(t.valueOrNull!.rail, rail);
        expect(t.valueOrNull!.status, isNot(equals('approved')));
      }
    });
  });

  group('BankimaHttpService retry', () {
    test('retries timeout then succeeds', () {
      fakeAsync((async) {
        var attempts = 0;
        final dio = Dio();
        dio.interceptors.add(InterceptorsWrapper(
          onRequest: (o, h) {
            attempts++;
            if (attempts < 3) {
              h.reject(
                DioException(requestOptions: o, type: DioExceptionType.connectionTimeout),
              );
              return;
            }
            h.resolve(Response(requestOptions: o, data: {
              'receiptCode': 'abc123',
              'amountToman': 1000,
              'occurredAt': DateTime.now().toIso8601String(),
              'status': 'settled',
            }, statusCode: 200));
          },
        ));
        final svc = BankimaHttpService(dio: dio, retry: const NetworkRetry(maxAttempts: 3, baseDelay: Duration.zero));
        late bool ok;
        svc.verifyTransaction('abc123').then((r) => ok = r.isRight());
        async.elapse(const Duration(seconds: 1));
        expect(attempts, 3);
        expect(ok, isTrue);
      });
    });
  });

  group('SmsParserService', () {
    final parser = BankSmsParser();

    test('parses six Iranian banks', () {
      final samples = DemoSmsInbox(now: DateTime(2026, 9, 12)).samples();
      expect(samples.map((s) => s.bank).toSet(), containsAll([
        IranianBank.mellat,
        IranianBank.melli,
        IranianBank.saderat,
        IranianBank.pasargad,
        IranianBank.saman,
        IranianBank.parsian,
      ]));
      for (final s in samples) {
        expect(s.amount, isNotNull);
        expect(s.trackingCode, isNotEmpty);
        expect(s.occurredAt, isNotNull);
      }
    });

    test('never auto-approves suggestions', () async {
      final repo = _MemTx();
      final svc = SmsParserService(
        inbox: DemoSmsInbox(now: DateTime(2026, 9, 12)),
        transactions: repo,
        parser: parser,
      );
      final res = await svc.ingestParsed(
        smsList: DemoSmsInbox(now: DateTime(2026, 9, 12)).samples(),
        existing: const [],
        members: const [],
      );
      expect(res.isRight(), isTrue);
      expect(res.valueOrNull!.autoApproved, isFalse);
      expect(repo.created.every((t) => t.status == TransactionStatus.pending), isTrue);
      expect(repo.created.every((t) => t.source == PaymentSource.smsMatch), isTrue);
      expect(repo.approveCount, 0);
    });
  });

  group('ReportBuilder', () {
    test('builds cashflow, overdue and member performance', () {
      final now = DateTime(2026, 9, 1);
      final fund = Fund(
        id: 'f',
        name: 'پولاد',
        inviteCode: 'POLAD1',
        adminId: 'a',
        shareAmount: 5000000,
        paymentPeriodDays: 30,
        serviceFeeRate: 0.005,
        loanAdminFeeRate: 0.02,
        createdAt: now,
        tier: SubscriptionTier.premium,
        memberCount: 1,
        balance: 10,
      );
      final member = FundMember(
        userId: 'u',
        fundId: 'f',
        role: UserRole.member,
        displayName: 'مریم',
        phone: '09121111111',
        joinedAt: now,
        shareBalance: 1,
        debt: 0,
        credit: 0,
      );
      final report = const ReportBuilder().build(
        fund: fund,
        transactions: [
          MoneyTransaction(
            id: '1',
            fundId: 'f',
            memberId: 'u',
            memberName: 'مریم',
            type: TransactionType.sharePayment,
            amount: 5000000,
            status: TransactionStatus.approved,
            occurredAt: now,
            submittedAt: now,
          ),
        ],
        installments: [
          Installment(
            id: 'i',
            loanId: 'l',
            fundId: 'f',
            memberId: 'u',
            sequence: 1,
            amount: 1000,
            dueDate: now,
            status: InstallmentStatus.overdue,
          ),
        ],
        loans: [
          Loan(
            id: 'l',
            fundId: 'f',
            memberId: 'u',
            memberName: 'مریم',
            amount: 1000,
            termMonths: 2,
            reason: 'x',
            status: LoanStatus.active,
            adminFeeRate: 0.02,
            requestedAt: now,
          ),
        ],
        members: [member],
        invoices: const [],
      );
      expect(report.summary.totalIn, 5000000);
      expect(report.overdue, isNotEmpty);
      expect(report.members.single.paidAmount, 5000000);
      expect(report.loanSlices.single.status, LoanStatus.active);
    });
  });
}

class _MemTx implements TransactionRepository {
  final created = <MoneyTransaction>[];
  int approveCount = 0;

  @override
  Future<Result<MoneyTransaction>> submit(SubmitPaymentInput input) async {
    final tx = MoneyTransaction(
      id: 's${created.length}',
      fundId: 'f',
      memberId: input.memberId ?? 'u',
      memberName: input.memberName ?? 'x',
      type: input.type,
      amount: input.amount,
      status: TransactionStatus.pending,
      occurredAt: input.occurredAt,
      submittedAt: DateTime(2026, 9, 12),
      trackingCode: input.trackingCode,
      source: input.source,
    );
    created.add(tx);
    return Ok(tx);
  }

  @override
  Future<Result<void>> approve(String transactionId, {String? note}) async {
    approveCount++;
    return const Ok(null);
  }

  @override
  Future<Result<void>> reject(String transactionId, {required String note}) => throw UnimplementedError();

  @override
  Stream<List<MoneyTransaction>> watchForFund(String fundId) => const Stream.empty();

  @override
  Stream<List<MoneyTransaction>> watchForMember(String fundId, String userId) => const Stream.empty();
}
