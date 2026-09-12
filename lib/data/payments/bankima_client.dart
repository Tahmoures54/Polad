import 'package:dio/dio.dart';

import '../../core/config/app_config.dart';
import '../../core/network/network_retry.dart';
import '../../core/utils/result.dart';
import '../../domain/enums.dart';
import 'bankima_models.dart';
import 'bankima_service.dart';

export 'bankima_models.dart';
export 'bankima_paths.dart';
export 'bankima_service.dart';

/// سازگاری با کد قدیمی. منطق جدید در [BankimaService] است.
///
/// Secrets MUST stay in Cloud Functions; this Dart client is only used against
/// a backend proxy, never with a raw client_secret inside the mobile app.
class BankimaClient {
  BankimaClient({Dio? dio, this.proxyBaseUrl, NetworkRetry? retry})
      : _http = BankimaHttpService(
          dio: dio,
          baseUrl: proxyBaseUrl ?? AppConfig.bankimaBaseUrl,
          retry: retry,
        );

  final BankimaHttpService _http;
  final String? proxyBaseUrl;

  BankimaService get service => _http;

  Future<Result<IbanInquiry>> inquireIban(String iban) async {
    // TODO(bankima-docs): استعلام شبا پس از دریافت قرارداد فیلدها.
    final res = await _http.verifyTransaction(iban);
    return res.fold(
      (f) => Err(f.message),
      (tx) => Ok(
        IbanInquiry(
          iban: iban,
          ownerName: tx.description ?? '',
          bankName: 'ملت',
          status: tx.status,
        ),
      ),
    );
  }

  Future<Result<List<BankTurnoverRow>>> turnover({
    required DateTime from,
    required DateTime to,
  }) async {
    final res = await _http.getAccountStatement('default', DateRange(from: from, to: to));
    return res.fold(
      (f) => Err(f.message),
      (s) => Ok(
        s.rows
            .map(
              (r) => BankTurnoverRow(
                amountToman: r.amountToman,
                trackingCode: r.trackingCode,
                isCredit: r.isCredit,
                occurredAt: r.occurredAt,
                description: r.description,
              ),
            )
            .toList(),
      ),
    );
  }

  Future<Result<String>> initiatePaya({
    required String destinationIban,
    required int amountToman,
    required String description,
    required String trackId,
  }) async {
    final res = await _http.transfer(
      rail: BankTransferRail.paya,
      destinationIban: destinationIban,
      amountToman: amountToman,
      description: description,
      trackId: trackId,
    );
    return res.fold((f) => Err(f.message), (t) => Ok(t.paymentId));
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
