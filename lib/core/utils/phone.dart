import 'validators.dart';

/// نرمال‌سازی و اعتبارسنجی شماره موبایل ایران برای OTP.
class IranianPhone {
  const IranianPhone._();

  /// تبدیل ارقام فارسی/عربی و پیش‌شماره به قالب `09xxxxxxxxx`.
  static String normalize(String phone) {
    var digits = Validators.toEnglishDigits(phone).replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0098')) {
      digits = digits.substring(4);
    } else if (digits.startsWith('98') && digits.length >= 12) {
      digits = digits.substring(2);
    }
    if (digits.startsWith('9') && digits.length == 10) {
      digits = '0$digits';
    }
    return digits;
  }

  /// آیا شماره پس از نرمال‌سازی یک موبایل ایرانی معتبر است؟
  static bool isValid(String phone) => Validators.phone(normalize(phone)) == null;

  /// قالب E.164 برای Firebase Auth (`+98912...`).
  static String toE164(String phone) {
    final normalized = normalize(phone);
    if (normalized.startsWith('0') && normalized.length == 11) {
      return '+98${normalized.substring(1)}';
    }
    if (phone.trim().startsWith('+')) return phone.trim();
    return '+98$normalized';
  }
}
