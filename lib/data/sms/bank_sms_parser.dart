import 'package:shamsi_date/shamsi_date.dart';

import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/finance.dart';
import '../../domain/enums.dart';

/// الگوی استخراج فیلد از پیامک یک بانک ایرانی.
class BankSmsPattern {
  const BankSmsPattern({
    required this.bank,
    required this.senders,
    required this.bodyHints,
    required this.amount,
    required this.tracking,
    required this.dates,
    required this.credit,
    required this.debit,
  });

  final IranianBank bank;
  final List<RegExp> senders;
  final List<RegExp> bodyHints;
  final List<RegExp> amount;
  final List<RegExp> tracking;
  final List<RegExp> dates;
  final List<RegExp> credit;
  final List<RegExp> debit;
}

/// پارسر پیامک بانکی مدیر.
///
/// فقط استخراج می‌کند؛ تأیید تراکنش صندوق هرگز اینجا انجام نمی‌شود.
class BankSmsParser {
  BankSmsParser({List<BankSmsPattern>? patterns}) : patterns = patterns ?? defaultPatterns;

  final List<BankSmsPattern> patterns;

  /// الگوهای ملت، ملی، صادرات، پاسارگاد، سامان، پارسیان.
  static final defaultPatterns = <BankSmsPattern>[
    BankSmsPattern(
      bank: IranianBank.mellat,
      senders: [
        RegExp(r'(bank)?mellat|bmellat|982000|50004011|ملت', caseSensitive: false),
      ],
      bodyHints: [RegExp(r'بانک\s*ملت')],
      amount: [
        RegExp(r'(?:واریز|برداشت|مبلغ)\s*:?\s*([\d,٬٫]+)\s*(?:تومان|ريال|ریال)?', caseSensitive: false),
      ],
      tracking: [
        RegExp(r'(?:کد\s*)?(?:پیگیری|پيگيري)\s*:?\s*([A-Za-z0-9]{6,30})', caseSensitive: false),
      ],
      dates: [_jalaliDate, _gregorianDate],
      credit: [RegExp(r'واریز|واريز|بستانکار')],
      debit: [RegExp(r'برداشت|بدهکار')],
    ),
    BankSmsPattern(
      bank: IranianBank.melli,
      senders: [
        RegExp(r'(bank)?melli|\bbmi\b|98200011|ملی', caseSensitive: false),
      ],
      bodyHints: [RegExp(r'بانک\s*ملی')],
      amount: [
        RegExp(r'مبلغ\s*:?\s*([\d,٬٫]+)\s*(?:ريال|ریال|تومان)', caseSensitive: false),
        RegExp(r'([\d,٬٫]{4,})\s*(?:ريال|ریال)\s*واریز', caseSensitive: false),
      ],
      tracking: [
        RegExp(r'(?:شماره\s*)?پیگیری\s*:?\s*([A-Za-z0-9]{6,30})', caseSensitive: false),
      ],
      dates: [_jalaliDate, _gregorianDate],
      credit: [RegExp(r'واریز|بستانکار')],
      debit: [RegExp(r'برداشت|بدهکار')],
    ),
    BankSmsPattern(
      bank: IranianBank.saderat,
      senders: [
        RegExp(r'(bank)?saderat|\bbsi\b|صادرات', caseSensitive: false),
      ],
      bodyHints: [RegExp(r'بانک\s*صادرات')],
      amount: [
        RegExp(r'واریز\s*مبلغ\s*([\d,٬٫]+)\s*(?:ريال|ریال|تومان)', caseSensitive: false),
        RegExp(r'مبلغ\s*:?\s*([\d,٬٫]+)', caseSensitive: false),
      ],
      tracking: [
        RegExp(r'پیگیری\s*:?\s*([A-Za-z0-9]{6,30})', caseSensitive: false),
      ],
      dates: [_jalaliDate, _gregorianDate],
      credit: [RegExp(r'واریز')],
      debit: [RegExp(r'برداشت')],
    ),
    BankSmsPattern(
      bank: IranianBank.pasargad,
      senders: [
        RegExp(r'(bank)?pasargad|\bbpi\b|98200057|پاسارگاد', caseSensitive: false),
      ],
      bodyHints: [RegExp(r'پاسارگاد')],
      amount: [
        RegExp(r'([+-])\s*([\d,٬٫]+)\s*(?:ريال|ریال|تومان)', caseSensitive: false),
        RegExp(r'مبلغ\s*:?\s*([\d,٬٫]+)', caseSensitive: false),
      ],
      tracking: [
        RegExp(r'(?:کد|sequence|sequense|رهگیری)\s*:?\s*([A-Za-z0-9]{6,30})', caseSensitive: false),
      ],
      dates: [_jalaliDate, _gregorianDate],
      credit: [RegExp(r'واریز|[+][\d]')],
      debit: [RegExp(r'برداشت')],
    ),
    BankSmsPattern(
      bank: IranianBank.saman,
      senders: [
        RegExp(r'(bank)?saman|sb24|سامان', caseSensitive: false),
      ],
      bodyHints: [RegExp(r'بانک\s*سامان')],
      amount: [
        RegExp(r'واریز\s*([\d,٬٫]+)\s*(?:تومان|ريال|ریال)', caseSensitive: false),
        RegExp(r'مبلغ\s*:?\s*([\d,٬٫]+)', caseSensitive: false),
      ],
      tracking: [
        RegExp(r'(?:شماره\s*)?(?:مرجع|پیگیری)\s*:?\s*([A-Za-z0-9]{6,30})', caseSensitive: false),
      ],
      dates: [_jalaliDate, _gregorianDate],
      credit: [RegExp(r'واریز')],
      debit: [RegExp(r'برداشت')],
    ),
    BankSmsPattern(
      bank: IranianBank.parsian,
      senders: [
        RegExp(r'(bank)?parsian|98200054|پارسیان', caseSensitive: false),
      ],
      bodyHints: [RegExp(r'بانک\s*پارسیان')],
      amount: [
        RegExp(r'مبلغ\s*(?:واریزی|برداشتی)?\s*:?\s*([\d,٬٫]+)\s*(?:تومان|ريال|ریال)?', caseSensitive: false),
      ],
      tracking: [
        RegExp(r'(?:کد\s*)?(?:رهگیری|پیگیری)\s*:?\s*([A-Za-z0-9]{6,30})', caseSensitive: false),
      ],
      dates: [_jalaliDate, _gregorianDate],
      credit: [RegExp(r'واریز')],
      debit: [RegExp(r'برداشت')],
    ),
  ];

  static final _jalaliDate = RegExp(r'(1[34]\d{2})[/-](\d{1,2})[/-](\d{1,2})');
  static final _gregorianDate = RegExp(r'(20\d{2})[/-](\d{1,2})[/-](\d{1,2})');
  static final _genericAmount = RegExp(
    r'(?:مبلغ|واریز|برداشت)\s*:?\s*([\d,٬٫]+)(?:\s*(?:ريال|ریال|تومان|﷼))?',
    caseSensitive: false,
  );
  static final _genericAmountAlt = RegExp(r'([\d,٬٫]{4,})\s*(?:ريال|ریال|تومان)');
  static final _genericTrack = RegExp(
    r'(?:پیگیری|پيگيري|کد پیگیری|رهگیری|مرجع|ref|reference)\s*:?\s*([A-Za-z0-9]{6,30})',
    caseSensitive: false,
  );
  static final _genericTrackAlt = RegExp(r'\b(\d{6,20})\b');

  IranianBank detectBank(String sender, String body) {
    final hay = '$sender\n$body';
    for (final p in patterns) {
      if (p.senders.any((r) => r.hasMatch(sender)) || p.bodyHints.any((r) => r.hasMatch(hay))) {
        return p.bank;
      }
    }
    return IranianBank.unknown;
  }

  BankSms parse(String sender, String body, DateTime receivedAt) {
    final en = Validators.toEnglishDigits(body).replaceAll('٬', ',').replaceAll('٫', '.');
    final bank = detectBank(sender, en);
    final pattern = patterns.where((p) => p.bank == bank).firstOrNull;
    final amount = _readAmount(en, extra: pattern?.amount ?? const []);
    final tracking = _readTracking(en, extra: pattern?.tracking ?? const []);
    final date = _readDate(en, extra: pattern?.dates ?? const []);
    bool? isCredit;
    final creditHit = [...?pattern?.credit, RegExp(r'(واریز|واريز|بستانکار|credit)', caseSensitive: false)]
        .any((r) => r.hasMatch(en));
    final debitHit = [...?pattern?.debit, RegExp(r'(برداشت|بدهکار|debit)', caseSensitive: false)]
        .any((r) => r.hasMatch(en));
    if (creditHit && !debitHit) isCredit = true;
    if (debitHit && !creditHit) isCredit = false;
    return BankSms(
      sender: sender,
      body: body,
      receivedAt: receivedAt,
      amount: amount,
      trackingCode: tracking,
      isCredit: isCredit,
      bank: bank,
      occurredAt: date,
      rawDate: date?.toIso8601String(),
    );
  }

  int? _readAmount(String body, {required List<RegExp> extra}) {
    Match? m;
    for (final r in [...extra, _genericAmount, _genericAmountAlt]) {
      m = r.firstMatch(body);
      if (m != null) break;
    }
    if (m == null) return null;
    final rawGroup = m.groupCount >= 2 && m.group(1) != null && RegExp(r'^[+-]$').hasMatch(m.group(1)!)
        ? m.group(2)
        : m.group(1);
    final raw = (rawGroup ?? '').replaceAll(',', '').replaceAll('٬', '');
    final n = int.tryParse(raw);
    if (n == null) return null;
    if (body.contains('ریال') || body.contains('ريال')) {
      return (n / 10).round();
    }
    return n;
  }

  String? _readTracking(String body, {required List<RegExp> extra}) {
    for (final r in [...extra, _genericTrack]) {
      final m = r.firstMatch(body);
      if (m != null) return m.group(1);
    }
    final all = _genericTrackAlt.allMatches(body).toList();
    if (all.length >= 2) return all.last.group(1);
    return all.isEmpty ? null : all.first.group(1);
  }

  DateTime? _readDate(String body, {required List<RegExp> extra}) {
    for (final r in [...extra, _jalaliDate, _gregorianDate]) {
      final m = r.firstMatch(body);
      if (m == null) continue;
      final y = int.tryParse(m.group(1)!);
      final mo = int.tryParse(m.group(2)!);
      final d = int.tryParse(m.group(3)!);
      if (y == null || mo == null || d == null) continue;
      try {
        if (y >= 1300 && y < 1600) {
          return Jalali(y, mo, d).toDateTime();
        }
        return DateTime(y, mo, d);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Result<MoneyTransaction> match({
    required BankSms sms,
    required List<MoneyTransaction> pending,
    Duration window = const Duration(days: 3),
  }) {
    if (sms.amount == null && (sms.trackingCode == null || sms.trackingCode!.isEmpty)) {
      return const Err('پیامک بانکی قابل تطبیق نیست');
    }
    final when = sms.occurredAt ?? sms.receivedAt;
    final candidates = pending.where((t) {
      final timeOk = t.submittedAt.difference(when).abs() <= window ||
          t.occurredAt.difference(when).abs() <= window;
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
