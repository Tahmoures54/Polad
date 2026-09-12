import 'package:intl/intl.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:shamsi_date/shamsi_date.dart';

final _num = NumberFormat('#,###', 'en');

String toman(int amount) {
  final signed = amount < 0 ? '−' : '';
  return '$signed${_num.format(amount.abs()).toPersianDigit()} تومان';
}

String tomanCompact(int amount) {
  if (amount.abs() >= 1000000000) {
    final v = amount / 1000000000;
    return '${v.toStringAsFixed(1).toPersianDigit()} میلیارد';
  }
  if (amount.abs() >= 1000000) {
    final v = amount / 1000000;
    return '${v.toStringAsFixed(v >= 10 ? 0 : 1).toPersianDigit()} میلیون';
  }
  return toman(amount);
}

String percentFa(double rate) =>
    '${(rate * 100).toStringAsFixed(rate * 100 % 1 == 0 ? 0 : 1).toPersianDigit()}٪';

String faDigits(Object value) => value.toString().toPersianDigit();

String jalaliDate(DateTime date) {
  final j = Jalali.fromDateTime(date);
  return '${faDigits(j.year)}/${faDigits(j.month.toString().padLeft(2, '0'))}/${faDigits(j.day.toString().padLeft(2, '0'))}';
}

String jalaliDateTime(DateTime date) {
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '${jalaliDate(date)}  ${faDigits(h)}:${faDigits(m)}';
}

int tomanToRial(int tomanAmount) => tomanAmount * 10;

int rialToToman(int rialAmount) => (rialAmount / 10).round();

String iranianPhonePretty(String phone) {
  final d = phone.replaceAll(RegExp(r'\D'), '');
  if (d.length == 11) {
    return '${d.substring(0, 4)} ${d.substring(4, 7)} ${d.substring(7)}'.toPersianDigit();
  }
  return phone.toPersianDigit();
}
