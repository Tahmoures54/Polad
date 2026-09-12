import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/result.dart';

/// Client for Bank Mellat Open Banking («بانکیما»).
///
/// Official endpoints and credentials are issued after commercial onboarding
/// on the Bankima partner portal. Secrets MUST stay in Cloud Functions;
/// this Dart client is only used against a backend proxy, never with a raw
/// client_secret inside the mobile app.
class BankimaClient {
  BankimaClient({Dio? dio, this.proxyBaseUrl})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: proxyBaseUrl ?? AppConfig.bankimaBaseUrl,
                connectTimeout: const Duration(seconds: 12),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;
  final String? proxyBaseUrl;

  Future<Result<IbanInquiry>> inquireIban(String iban) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/v1/iban/inquiry', queryParameters: {'iban': iban});
      final data = res.data ?? const {};
      return Ok(IbanInquiry(
        iban: iban,
        ownerName: data['ownerName'] as String? ?? '',
        bankName: data['bankName'] as String? ?? 'ملت',
        status: data['status'] as String? ?? 'unknown',
      ));
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  Future<Result<List<BankTurnoverRow>>> turnover({
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/v1/accounts/turnover', queryParameters: {
        'from': from.toIso8601String(),
        'to': to.toIso8601String(),
      });
      final rows = (res.data?['items'] as List? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .map(
            (m) => BankTurnoverRow(
              amountToman: rialToToman(m['amountRial'] as int? ?? 0),
              trackingCode: m['trackingCode'] as String? ?? '',
              isCredit: m['isCredit'] as bool? ?? true,
              occurredAt: DateTime.tryParse(m['occurredAt'] as String? ?? '') ?? DateTime.now(),
              description: m['description'] as String? ?? '',
            ),
          )
          .toList();
      return Ok(rows);
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  Future<Result<String>> initiatePaya({
    required String destinationIban,
    required int amountToman,
    required String description,
    required String trackId,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/v1/payments/paya', data: {
        'destinationIban': destinationIban,
        'amountRial': tomanToRial(amountToman),
        'description': description,
        'trackId': trackId,
      });
      final id = res.data?['paymentId'] as String?;
      if (id == null) return const Err('بانکیما شناسه پرداخت برنگرداند');
      return Ok(id);
    } on DioException catch (e) {
      return Err(_mapError(e));
    }
  }

  String _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'ارتباط با بانکیما زمان‌بر شد. بعداً دوباره تلاش کنید.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'اینترنت در دسترس نیست.';
    }
    return 'خطای بانکیما: ${e.response?.statusCode ?? ''}';
  }
}

class IbanInquiry {
  const IbanInquiry({required this.iban, required this.ownerName, required this.bankName, required this.status});
  final String iban;
  final String ownerName;
  final String bankName;
  final String status;
}

class BankTurnoverRow {
  const BankTurnoverRow({
    required this.amountToman,
    required this.trackingCode,
    required this.isCredit,
    required this.occurredAt,
    required this.description,
  });
  final int amountToman;
  final String trackingCode;
  final bool isCredit;
  final DateTime occurredAt;
  final String description;
}
