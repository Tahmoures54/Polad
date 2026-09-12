import '../../domain/entities/finance.dart';
import '../../domain/enums.dart';
import '../../domain/repositories/repositories.dart';
import 'bank_sms_parser.dart';

/// اینباکس ساختگی برای حالت دمو و تست — شش بانک پشتیبانی‌شده.
class DemoSmsInbox implements SmsInbox {
  DemoSmsInbox({BankSmsParser? parser, DateTime? now, this.grantPermission = true})
      : _parser = parser ?? BankSmsParser(),
        _now = now ?? DateTime.now();

  final BankSmsParser _parser;
  final DateTime _now;
  bool grantPermission;

  /// نمونه‌های واقعی‌نما برای ملت، ملی، صادرات، پاسارگاد، سامان، پارسیان.
  List<BankSms> samples() {
    final t = _now;
    return [
      _parser.parse(
        'BankMellat',
        'بانک ملت\nواریز: ۵٬۰۰۰٬۰۰۰ تومان\nکد پیگیری: 1403123456\n1405/06/21',
        t.subtract(const Duration(hours: 5)),
      ),
      _parser.parse(
        'BankMelli',
        'بانک ملی ایران\nمبلغ: ۵۰۰۰۰۰۰۰ ریال واریز به حساب\nشماره پیگیری: 55667788\nتاریخ: 1405/06/20',
        t.subtract(const Duration(days: 1)),
      ),
      _parser.parse(
        'BankSaderat',
        'بانک صادرات\nواریز مبلغ 30,000,000 ریال\nپیگیری: 33445566\n1405/06/19',
        t.subtract(const Duration(days: 2)),
      ),
      _parser.parse(
        'BankPasargad',
        'پاسارگاد\n+2,000,000 تومان\nکد رهگیری: 77889900\n1405/06/18',
        t.subtract(const Duration(days: 3)),
      ),
      _parser.parse(
        'SB24',
        'بانک سامان\nواریز 1,500,000 تومان\nشماره مرجع: SMN123456\n1405/06/17',
        t.subtract(const Duration(days: 4)),
      ),
      _parser.parse(
        'BankParsian',
        'بانک پارسیان\nمبلغ واریزی: 4,000,000 تومان\nکد رهگیری: 44556677\nتاریخ 1405/06/16 14:30',
        t.subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Future<bool> requestPermission() async => grantPermission;

  @override
  Future<List<BankSms>> readRecent({Duration window = const Duration(days: 7)}) async {
    if (!grantPermission) return const [];
    return samples()
        .where((s) => _now.difference(s.receivedAt) <= window)
        .toList();
  }
}

/// نگهبان قرارداد: پیشنهاد پیامک باید همیشه `pending_approval` بماند.
bool smsSuggestionIsPending(MoneyTransaction tx) {
  return tx.source == PaymentSource.smsMatch && tx.status == TransactionStatus.pending;
}
