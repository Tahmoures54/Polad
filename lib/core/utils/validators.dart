class Validators {
  static final _phone = RegExp(r'^09\d{9}$');
  static final _iban = RegExp(r'^IR\d{24}$');
  static final _tracking = RegExp(r'^[0-9A-Za-z]{6,30}$');

  static String? phone(String? value) {
    final normalized = toEnglishDigits(value ?? '');
    if (normalized.isEmpty) return 'شماره موبایل را وارد کنید';
    if (!_phone.hasMatch(normalized)) return 'شماره موبایل معتبر نیست';
    return null;
  }

  static String? otp(String? value) {
    final v = toEnglishDigits(value ?? '');
    if (v.length != 6) return 'کد ۶ رقمی را وارد کنید';
    return null;
  }

  static String? requiredText(String? value, {String label = 'این مقدار'}) {
    if ((value ?? '').trim().isEmpty) return '$label را وارد کنید';
    return null;
  }

  static String? amount(String? value, {int min = 10000}) {
    final n = parseAmount(value);
    if (n == null) return 'مبلغ را وارد کنید';
    if (n < min) return 'مبلغ خیلی کم است';
    return null;
  }

  static String? trackingCode(String? value) {
    final v = toEnglishDigits(value ?? '').trim();
    if (v.isEmpty) return 'کد پیگیری را وارد کنید';
    if (!_tracking.hasMatch(v)) return 'کد پیگیری نامعتبر است';
    return null;
  }

  static String? iban(String? value) {
    final v = (value ?? '').replaceAll(' ', '').toUpperCase();
    if (v.isEmpty) return null;
    if (!_iban.hasMatch(v)) return 'شبا باید با IR و ۲۴ رقم باشد';
    return null;
  }

  static int? parseAmount(String? value) {
    final v = toEnglishDigits(value ?? '').replaceAll(RegExp(r'[^\d]'), '');
    if (v.isEmpty) return null;
    return int.tryParse(v);
  }

  static String toEnglishDigits(String input) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    final buf = StringBuffer();
    for (final ch in input.split('')) {
      final fi = fa.indexOf(ch);
      if (fi >= 0) {
        buf.write(fi);
        continue;
      }
      final ai = ar.indexOf(ch);
      if (ai >= 0) {
        buf.write(ai);
        continue;
      }
      buf.write(ch);
    }
    return buf.toString();
  }
}
