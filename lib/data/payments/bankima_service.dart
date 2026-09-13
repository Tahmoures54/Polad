import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../core/error/app_result.dart';
import '../../core/error/failure.dart';
import '../../core/network/guard.dart';
import '../../core/network/network_retry.dart';
import '../../core/utils/formatters.dart';
import '../../domain/enums.dart';
import '../services/functions_service.dart';
import 'bankima_models.dart';
import 'bankima_paths.dart';

/// سرویس بانکیما برای صندوق خانوادگی پولاد.
///
/// راهنما:
/// * کلاینت موبایل این متدها را صدا می‌زند؛ در تولید درخواست به Cloud Functions
///   می‌رود تا `client_secret` روی گوشی نباشد.
/// * استعلام موفق بانکی **هرگز** تراکنش صندوق را تأیید نمی‌کند. مدیر باید در
///   صف «در انتظار تأیید» تصمیم بگیرد.
/// * باهمتا پشتیبانی نمی‌شود.
abstract class BankimaService {
  /// استعلام تراکنش با کد رسید / پیگیری.
  Future<AppResult<BankimaVerifiedTx>> verifyTransaction(String receiptCode);

  /// گردش حساب در بازهٔ تاریخ.
  Future<AppResult<BankimaStatement>> getAccountStatement(String accountId, DateRange dateRange);

  /// اطلاعات اقساط تسهیلات سمت بانک (نه جدول داخلی صندوق).
  Future<AppResult<BankimaInstallmentInfo>> getInstallmentInfo(String loanId);

  /// تولید لینک پرداخت برای عضو. نتیجه فقط لینک است؛ موجودی صندوق عوض نمی‌شود.
  Future<AppResult<BankimaPaymentLink>> createPaymentLink(String memberId, int amountToman);

  /// موجودی حساب معرفی‌شده در بانکیما.
  Future<AppResult<BankimaBalance>> getBalance(String accountId);

  /// انتقال وجه از طریق پایا / ساتنا / پل.
  Future<AppResult<BankimaTransferResult>> transfer({
    required BankTransferRail rail,
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  });

  Future<AppResult<BankimaTransferResult>> initiatePaya({
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  }) =>
      transfer(
        rail: BankTransferRail.paya,
        destinationIban: destinationIban,
        amountToman: amountToman,
        description: description,
        trackId: trackId,
      );

  Future<AppResult<BankimaTransferResult>> initiateSatna({
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  }) =>
      transfer(
        rail: BankTransferRail.satna,
        destinationIban: destinationIban,
        amountToman: amountToman,
        description: description,
        trackId: trackId,
      );

  Future<AppResult<BankimaTransferResult>> initiatePol({
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  }) =>
      transfer(
        rail: BankTransferRail.pol,
        destinationIban: destinationIban,
        amountToman: amountToman,
        description: description,
        trackId: trackId,
      );
}

/// حالت دمو / آزمایش بدون فراخوانی شبکه. برای `POLAD_DEMO=true`.
class DemoBankimaService extends BankimaService {
  DemoBankimaService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  static const demoAccount = '1234567890';
  static const demoReceipt = '1403123456';

  @override
  Future<AppResult<BankimaVerifiedTx>> verifyTransaction(String receiptCode) async {
    if (receiptCode.trim().length < 6) {
      return left(const UnexpectedFailure(message: 'کد پیگیری برای استعلام کوتاه است'));
    }
    return right(
      BankimaVerifiedTx(
        receiptCode: receiptCode.trim(),
        amountToman: receiptCode.trim() == demoReceipt ? 5000000 : 1000000,
        occurredAt: DateTime.now().subtract(const Duration(hours: 6)),
        status: 'settled',
        description: 'استعلام دمو بانکیما — تأیید صندوق انجام نشد',
      ),
    );
  }

  @override
  Future<AppResult<BankimaStatement>> getAccountStatement(String accountId, DateRange dateRange) async {
    if (!dateRange.isValid) {
      return left(const UnexpectedFailure(message: 'بازهٔ تاریخ نامعتبر است'));
    }
    return right(
      BankimaStatement(
        accountId: accountId,
        range: dateRange,
        rows: [
          BankimaStatementRow(
            amountToman: 5000000,
            trackingCode: demoReceipt,
            isCredit: true,
            occurredAt: DateTime.now().subtract(const Duration(days: 1)),
            description: 'واریز سهم — دمو',
          ),
          BankimaStatementRow(
            amountToman: 5100000,
            trackingCode: '99887766',
            isCredit: true,
            occurredAt: DateTime.now().subtract(const Duration(days: 2)),
            description: 'واریز قسط — دمو',
          ),
        ],
      ),
    );
  }

  @override
  Future<AppResult<BankimaInstallmentInfo>> getInstallmentInfo(String loanId) async {
    if (loanId.trim().isEmpty) {
      return left(const UnexpectedFailure(message: 'شناسه تسهیلات لازم است'));
    }
    return right(
      BankimaInstallmentInfo(
        loanId: loanId,
        principalToman: 50000000,
        remainingToman: 40000000,
        installments: [
          BankimaInstallmentRow(
            sequence: 1,
            amountToman: 5100000,
            dueDate: DateTime.now().subtract(const Duration(days: 20)),
            paid: true,
          ),
          BankimaInstallmentRow(
            sequence: 2,
            amountToman: 5100000,
            dueDate: DateTime.now().add(const Duration(days: 10)),
            paid: false,
          ),
        ],
      ),
    );
  }

  @override
  Future<AppResult<BankimaPaymentLink>> createPaymentLink(String memberId, int amountToman) async {
    if (memberId.isEmpty || amountToman <= 0) {
      return left(const UnexpectedFailure(message: 'عضو و مبلغ برای لینک پرداخت لازم است'));
    }
    final orderId = _uuid.v4();
    return right(
      BankimaPaymentLink(
        orderId: orderId,
        url: 'https://pay.bankima.ir/demo?member=$memberId&amount=$amountToman&order=$orderId',
        memberId: memberId,
        amountToman: amountToman,
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      ),
    );
  }

  @override
  Future<AppResult<BankimaBalance>> getBalance(String accountId) async {
    if (accountId.trim().isEmpty) {
      return left(const UnexpectedFailure(message: 'شناسه حساب لازم است'));
    }
    return right(
      BankimaBalance(
        accountId: accountId,
        availableToman: 185000000,
        blockedToman: 0,
        asOf: DateTime.now(),
      ),
    );
  }

  @override
  Future<AppResult<BankimaTransferResult>> transfer({
    required BankTransferRail rail,
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  }) async {
    if (destinationIban.trim().length < 24 || amountToman <= 0) {
      return left(const UnexpectedFailure(message: 'شبا یا مبلغ انتقال نامعتبر است'));
    }
    final id = trackId ?? _uuid.v4();
    return right(
      BankimaTransferResult(
        rail: rail,
        paymentId: 'demo-${rail.name}-$id',
        trackId: id,
        amountToman: amountToman,
        status: 'submitted',
        destinationIban: destinationIban,
      ),
    );
  }
}

/// پیاده‌سازی تولید: همهٔ درخواست‌ها از Cloud Functions با retry عبور می‌کنند.
class CallableBankimaService extends BankimaService {
  CallableBankimaService(this._fn, {NetworkRetry? retry}) : _retry = retry ?? NetworkRetry.standard;

  final FunctionsService _fn;
  final NetworkRetry _retry;

  Future<AppResult<T>> _call<T>(
    String name,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) parse,
  ) {
    return guardNetwork(() async {
      final res = await _fn.call(name, data);
      return res.fold((f) => throw f, parse);
    }, retry: _retry);
  }

  @override
  Future<AppResult<BankimaVerifiedTx>> verifyTransaction(String receiptCode) {
    return _call(
      CallableNames.bankimaVerifyTransaction,
      {'receiptCode': receiptCode},
      (m) => BankimaVerifiedTx.fromJson(m, fallbackCode: receiptCode),
    );
  }

  @override
  Future<AppResult<BankimaStatement>> getAccountStatement(String accountId, DateRange dateRange) {
    return _call(
      CallableNames.bankimaAccountStatement,
      {
        'accountId': accountId,
        'from': dateRange.from.toIso8601String(),
        'to': dateRange.to.toIso8601String(),
      },
      (m) {
        final items = (m['items'] as List? ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .map(BankimaStatementRow.fromJson)
            .toList();
        return BankimaStatement(accountId: accountId, range: dateRange, rows: items);
      },
    );
  }

  @override
  Future<AppResult<BankimaInstallmentInfo>> getInstallmentInfo(String loanId) {
    return _call(
      CallableNames.bankimaInstallmentInfo,
      {'loanId': loanId},
      (m) => BankimaInstallmentInfo.fromJson(loanId, m),
    );
  }

  @override
  Future<AppResult<BankimaPaymentLink>> createPaymentLink(String memberId, int amountToman) {
    return _call(
      CallableNames.bankimaCreatePaymentLink,
      {'memberId': memberId, 'amountToman': amountToman},
      BankimaPaymentLink.fromJson,
    );
  }

  @override
  Future<AppResult<BankimaBalance>> getBalance(String accountId) {
    return _call(
      CallableNames.bankimaGetBalance,
      {'accountId': accountId},
      (m) => BankimaBalance.fromJson(accountId, m),
    );
  }

  @override
  Future<AppResult<BankimaTransferResult>> transfer({
    required BankTransferRail rail,
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  }) {
    return _call(
      CallableNames.bankimaTransfer,
      {
        'rail': rail.wire,
        'destinationIban': destinationIban,
        'amountToman': amountToman,
        'description': description,
        'trackId': trackId,
      },
      (m) => BankimaTransferResult.fromJson(m, rail),
    );
  }
}

/// کلاینت HTTP برای پروکسی مورد اعتماد (تست یا Functions HTTP).
///
/// اپ فروشگاه باید [CallableBankimaService] را استفاده کند، نه این کلاس با secret.
class BankimaHttpService extends BankimaService {
  BankimaHttpService({
    Dio? dio,
    String? baseUrl,
    NetworkRetry? retry,
  })  : _retry = retry ?? NetworkRetry.standard,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl ?? 'https://api.bankima.ir',
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;
  final NetworkRetry _retry;

  Future<AppResult<T>> _run<T>(Future<T> Function() action) {
    return guardNetwork(() async {
      try {
        return await _retry.run(action);
      } on DioException catch (e) {
        throw _mapDio(e);
      }
    }, retry: const NetworkRetry(maxAttempts: 1));
  }

  @override
  Future<AppResult<BankimaVerifiedTx>> verifyTransaction(String receiptCode) {
    return _run(() async {
      // TODO(bankima-docs): نام پارامتر کد رسید را با PDF رسمی تطبیق دهید.
      final res = await _dio.get<Map<String, dynamic>>(
        BankimaPaths.verifyTransaction,
        queryParameters: {'receiptCode': receiptCode},
      );
      return BankimaVerifiedTx.fromJson(res.data ?? const {}, fallbackCode: receiptCode);
    });
  }

  @override
  Future<AppResult<BankimaStatement>> getAccountStatement(String accountId, DateRange dateRange) {
    return _run(() async {
      final path = BankimaPaths.interpolate(BankimaPaths.accountStatement, {'accountId': accountId});
      final res = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {
          'from': dateRange.from.toIso8601String(),
          'to': dateRange.to.toIso8601String(),
        },
      );
      final items = (res.data?['items'] as List? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(BankimaStatementRow.fromJson)
          .toList();
      return BankimaStatement(accountId: accountId, range: dateRange, rows: items);
    });
  }

  @override
  Future<AppResult<BankimaInstallmentInfo>> getInstallmentInfo(String loanId) {
    return _run(() async {
      final path = BankimaPaths.interpolate(BankimaPaths.installmentInfo, {'loanId': loanId});
      final res = await _dio.get<Map<String, dynamic>>(path);
      return BankimaInstallmentInfo.fromJson(loanId, res.data ?? const {});
    });
  }

  @override
  Future<AppResult<BankimaPaymentLink>> createPaymentLink(String memberId, int amountToman) {
    return _run(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        BankimaPaths.paymentLink,
        data: {
          'memberId': memberId,
          'amountRial': tomanToRial(amountToman),
        },
      );
      return BankimaPaymentLink.fromJson({
        ...?res.data,
        'memberId': memberId,
        'amountToman': amountToman,
      });
    });
  }

  @override
  Future<AppResult<BankimaBalance>> getBalance(String accountId) {
    return _run(() async {
      final path = BankimaPaths.interpolate(BankimaPaths.balance, {'accountId': accountId});
      final res = await _dio.get<Map<String, dynamic>>(path);
      return BankimaBalance.fromJson(accountId, res.data ?? const {});
    });
  }

  @override
  Future<AppResult<BankimaTransferResult>> transfer({
    required BankTransferRail rail,
    required String destinationIban,
    required int amountToman,
    required String description,
    String? trackId,
  }) {
    return _run(() async {
      final res = await _dio.post<Map<String, dynamic>>(
        BankimaPaths.forRail(rail.wire),
        data: {
          'destinationIban': destinationIban,
          'amountRial': tomanToRial(amountToman),
          'description': description,
          'trackId': trackId,
        },
      );
      return BankimaTransferResult.fromJson({
        ...?res.data,
        'amountToman': amountToman,
        'destinationIban': destinationIban,
      }, rail);
    });
  }

  Failure _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkFailure(
          message: 'ارتباط با بانکیما زمان‌بر شد. بعداً دوباره تلاش کنید.',
          code: 'deadline-exceeded',
        );
      case DioExceptionType.connectionError:
        return const NetworkFailure(message: 'اینترنت در دسترس نیست.', code: 'unavailable');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        if (code == 401 || code == 403) {
          return const PermissionFailure(message: 'دسترسی بانکیما رد شد', code: 'permission-denied');
        }
        if (code == 404) {
          return const NotFoundFailure(message: 'مورد درخواستی در بانکیما پیدا نشد');
        }
        if (code >= 500) {
          return NetworkFailure(
            message: 'سرویس بانکیما موقتاً در دسترس نیست.',
            code: 'unavailable',
            cause: e,
          );
        }
        return ServerFailure(message: 'خطای بانکیما: $code', code: 'bankima', cause: e);
      default:
        return ServerFailure(message: 'خطای بانکیما', code: 'bankima', cause: e);
    }
  }
}
