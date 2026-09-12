import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/finance.dart';

/// Parses Iranian bank SMS (Mellat / Shaparak style) into amount + tracking code.
class BankSmsParser {
  static final _amount = RegExp(
    r'(?:مبلغ|واریز|برداشت)\s*:?\s*([\d,٬٫]+)(?:\s*(?:ريال|ریال|تومان|﷼))?',
    caseSensitive: false,
  );
  static final _amountAlt = RegExp(r'([\d,٬٫]{4,})\s*(?:ريال|ریال|تومان)');
  static final _track = RegExp(
    r'(?:پیگیری|پيگيري|کد پیگیری|ref|reference)\s*:?\s*([A-Za-z0-9]{6,30})',
    caseSensitive: false,
  );
  static final _trackAlt = RegExp(r'\b(\d{6,20})\b');
  static final _credit = RegExp(r'(واریز|واريز|بستانکار|credit)', caseSensitive: false);
  static final _debit = RegExp(r'(برداشت|بدهکار|debit)', caseSensitive: false);

  BankSms parse(String sender, String body, DateTime receivedAt) {
    final en = Validators.toEnglishDigits(body).replaceAll('٬', ',').replaceAll('٫', '.');
    final amount = _readAmount(en);
    final tracking = _readTracking(en);
    bool? isCredit;
    if (_credit.hasMatch(en) && !_debit.hasMatch(en)) isCredit = true;
    if (_debit.hasMatch(en) && !_credit.hasMatch(en)) isCredit = false;
    return BankSms(
      sender: sender,
      body: body,
      receivedAt: receivedAt,
      amount: amount,
      trackingCode: tracking,
      isCredit: isCredit,
    );
  }

  int? _readAmount(String body) {
    final m = _amount.firstMatch(body) ?? _amountAlt.firstMatch(body);
    if (m == null) return null;
    final raw = m.group(1)!.replaceAll(',', '').replaceAll('٬', '');
    final n = int.tryParse(raw);
    if (n == null) return null;
    if (body.contains('ریال') || body.contains('ريال')) {
      return (n / 10).round();
    }
    return n;
  }

  String? _readTracking(String body) {
    final m = _track.firstMatch(body);
    if (m != null) return m.group(1);
    final all = _trackAlt.allMatches(body).toList();
    if (all.length >= 2) return all.last.group(1);
    return all.isEmpty ? null : all.first.group(1);
  }

  Result<MoneyTransaction> match({
    required BankSms sms,
    required List<MoneyTransaction> pending,
    Duration window = const Duration(days: 3),
  }) {
    if (sms.amount == null && (sms.trackingCode == null || sms.trackingCode!.isEmpty)) {
      return const Err('پیامک بانکی قابل تطبیق نیست');
    }
    final candidates = pending.where((t) {
      final timeOk = t.submittedAt.difference(sms.receivedAt).abs() <= window ||
          t.occurredAt.difference(sms.receivedAt).abs() <= window;
      final amountOk = sms.amount == null || sms.amount == t.amount;
      final codeOk = sms.trackingCode == null ||
          t.trackingCode == null ||
          t.trackingCode == sms.trackingCode;
      return timeOk && amountOk && codeOk;
    }).toList();
    if (candidates.isEmpty) return const Err('تراکنش متناظر پیدا نشد');
    if (candidates.length > 1 && sms.trackingCode != null) {
      final exact = candidates.where((t) => t.trackingCode == sms.trackingCode);
      if (exact.length == 1) return Ok(exact.first);
    }
    if (candidates.length == 1) return Ok(candidates.first);
    return const Err('چند تراکنش مشابه است؛ تطبیق دستی لازم است');
  }
}
