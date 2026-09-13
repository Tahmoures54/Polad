import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:polad/core/error/app_result.dart';
import 'package:polad/core/error/failure.dart';
import 'package:polad/core/network/network_retry.dart';
import 'package:polad/core/utils/phone.dart';
import 'package:polad/core/utils/result.dart';
import 'package:polad/data/demo/demo_backend.dart';
import 'package:polad/data/local/cache_store.dart';
import 'package:polad/data/models/models.dart';
import 'package:polad/data/services/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final now = DateTime.utc(2026, 9, 12);

  group('IranianPhone', () {
    test('normalizes persian digits and E.164', () {
      expect(IranianPhone.normalize('۰۹۱۲۰۰۰۰۰۰۰'), '09120000000');
      expect(IranianPhone.isValid('9120000000'), isTrue);
      expect(IranianPhone.toE164('09120000000'), '+989120000000');
      expect(IranianPhone.isValid('123'), isFalse);
    });
  });

  group('Either / Result', () {
    test('AppResult converts to Ok/Err', () {
      const AppResult<int> ok = Right(7);
      const AppResult<int> bad = Left(NetworkFailure(message: 'قطع'));
      expect(ok.toResult(), isA<Ok<int>>());
      expect(ok.toResult().valueOrNull, 7);
      expect(bad.toResult(), isA<Err<int>>());
      expect(bad.failureOrNull, isA<NetworkFailure>());
    });
  });

  group('NetworkRetry', () {
    test('retries retryable network failures then succeeds', () {
      fakeAsync((async) {
        var attempts = 0;
        final retry = const NetworkRetry(
          maxAttempts: 3,
          baseDelay: Duration(milliseconds: 10),
        );
        late int result;
        retry.run(() async {
          attempts++;
          if (attempts < 3) {
            throw const NetworkFailure(message: 'قطع', code: 'unavailable');
          }
          return 1;
        }).then((v) => result = v);
        async.elapse(const Duration(seconds: 1));
        expect(attempts, 3);
        expect(result, 1);
      });
    });

    test('does not retry auth failures', () async {
      var attempts = 0;
      final retry = const NetworkRetry(maxAttempts: 3, baseDelay: Duration.zero);
      await expectLater(
        retry.run(() async {
          attempts++;
          throw const AuthFailure(message: 'کد نادرست', code: 'invalid-verification-code');
        }),
        throwsA(isA<AuthFailure>()),
      );
      expect(attempts, 1);
    });
  });

  group('InMemoryFirestoreService', () {
    late InMemoryFirestoreService db;

    setUp(() => db = InMemoryFirestoreService());

    test('CRUD for all collections', () async {
      final user = User(
        uid: 'u1',
        name: 'طهمورث',
        phone: '09120000000',
        role: UserRole.admin,
        fundIds: const ['f1'],
        createdAt: now,
      );
      final fund = Fund(
        fundId: 'f1',
        name: 'صندوق خانوادگی پولاد',
        ownerId: 'u1',
        shareAmount: 5000000,
        periodType: FundPeriodType.monthly,
        feeRate: 0.005,
        createdAt: now,
      );
      final tx = Transaction(
        transactionId: 't1',
        fundId: 'f1',
        memberId: 'u2',
        amount: 5000000,
        date: now,
        status: TransactionStatus.pendingApproval,
        type: TransactionType.installment,
        submittedAt: now,
      );
      final loan = Loan(
        loanId: 'l1',
        fundId: 'f1',
        memberId: 'u2',
        amount: 10000000,
        installmentsCount: 10,
        status: LoanStatus.pending,
        feeRate: 0.02,
        createdAt: now,
      );
      final inst = Installment(
        installmentId: 'i1',
        loanId: 'l1',
        memberId: 'u2',
        amount: 1020000,
        dueDate: now.add(const Duration(days: 30)),
        status: InstallmentStatus.pending,
      );
      final draw = Draw(
        drawId: 'd1',
        fundId: 'f1',
        period: '1404-07',
        method: DrawMethod.random,
      );
      final fee = Fee(
        feeId: 'fee1',
        fundId: 'f1',
        month: '1404-06',
        totalAmount: 25000,
        status: FeeStatus.pending,
      );

      expect((await db.upsertUser(user)).isRight(), isTrue);
      expect((await db.upsertFund(fund)).isRight(), isTrue);
      expect((await db.upsertTransaction(tx)).isRight(), isTrue);
      expect((await db.upsertLoan(loan)).isRight(), isTrue);
      expect((await db.upsertInstallment(inst)).isRight(), isTrue);
      expect((await db.upsertDraw(draw)).isRight(), isTrue);
      expect((await db.upsertFee(fee)).isRight(), isTrue);

      expect((await db.getUser('u1')).getOrElse(() => throw ''), user);
      expect((await db.listFundsForUser('u1')).getOrElse(() => []), [fund]);
      expect(
        (await db.listTransactions(fundId: 'f1', status: TransactionStatus.pendingApproval))
            .getOrElse(() => []),
        [tx],
      );
      expect((await db.listLoans(fundId: 'f1', memberId: 'u2')).getOrElse(() => []), [loan]);
      expect((await db.listInstallments(fundId: 'f1')).getOrElse(() => []), [inst]);
      expect((await db.listDraws(fundId: 'f1')).getOrElse(() => []), [draw]);
      expect((await db.listFees(fundId: 'f1')).getOrElse(() => []), [fee]);

      expect((await db.getUser('missing')).isLeft(), isTrue);

      await db.deleteTransaction('t1');
      expect((await db.getTransaction('t1')).isLeft(), isTrue);
    });
  });

  group('Demo services', () {
    late DemoStore store;
    late Directory tempDir;
    late Box<String> box;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('polad_svc_');
      Hive.init(tempDir.path);
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      box = await Hive.openBox<String>('cache_${DateTime.now().microsecondsSinceEpoch}');
      final prefs = await SharedPreferences.getInstance();
      store = DemoStore(CacheStore(box, prefs));
      await store.load();
    });

    tearDown(() async {
      if (box.isOpen) await box.close();
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('DemoAuthService OTP and claims', () async {
      final auth = DemoAuthService(store);
      final sent = await auth.sendOtp('09120000000');
      expect(sent.isRight(), isTrue);

      final bad = await auth.verifyOtp(
        verificationId: 'x',
        smsCode: '000000',
        phone: '09120000000',
      );
      expect(bad.fold((f) => f, (_) => null), isA<AuthFailure>());

      final ok = await auth.verifyOtp(
        verificationId: 'x',
        smsCode: '۱۲۳۴۵۶',
        phone: '09120000000',
      );
      expect(ok.isRight(), isTrue);
      expect(ok.getOrElse(() => throw '').role, UserRole.admin);

      final claims = await auth.readCustomClaims();
      expect(claims.getOrElse(() => throw '').isAdmin, isTrue);

      await auth.signOut();
      expect(auth.currentUser, isNull);
    });

    test('Functions, storage, notifications', () async {
      final fn = DemoFunctionsService();
      final storage = DemoStorageService();
      final push = DemoNotificationService();

      expect((await fn.approveTransaction('t1', note: 'ok')).isRight(), isTrue);
      expect(fn.calls.single['name'], CallableNames.approveTransaction);

      await fn.setCustomClaims(uid: 'u2', role: UserRole.member, fundId: 'f1');
      expect(fn.claims['u2']?['role'], 'member');

      final uploaded = await storage.uploadReceipt(
        file: File('${tempDir.path}/x.jpg'),
        fundId: 'f1',
        transactionId: 't1',
      );
      expect(uploaded.getOrElse(() => throw '').downloadUrl, contains('demo://'));

      await push.initialize();
      await push.subscribeToFund('f1');
      await push.showLocal(title: 'تأیید', body: 'پرداخت ثبت شد');
      expect(push.subscribed, contains('fund_f1'));
      expect(push.localShown, isNotEmpty);
      expect((await push.getToken()).getOrElse(() => null), 'demo-fcm-token');
    });
  });
}
