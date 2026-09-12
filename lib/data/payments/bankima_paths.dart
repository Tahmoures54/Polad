/// مسیرهای HTTP بانکیما.
///
/// باهمتا تعطیل شده است؛ پولاد فقط از بانکیما (بانکداری باز بانک ملت) استفاده می‌کند.
///
/// مستندات کامل، sandbox و قرارداد فیلدها پس از ثبت‌نام تجاری روی پرتال شریک
/// بانکیما صادر می‌شود. تا آن زمان این ثابت‌ها **قرارداد پایدار پولاد** هستند و
/// هر مسیر با `TODO(bankima-docs)` مشخص شده تا پس از دریافت PDF رسمی جایگزین شود.
///
/// اسرار (`client_id` / `client_secret`) هرگز داخل اپ موبایل قرار نمی‌گیرند؛
/// فقط Cloud Functions آن‌ها را می‌بیند.
abstract final class BankimaPaths {
  /// TODO(bankima-docs): تأیید مسیر OAuth2 client-credentials در پرتال بانکیما.
  static const token = '/oauth/token';

  /// TODO(bankima-docs): استعلام تراکنش با کد پیگیری / رسید.
  static const verifyTransaction = '/v1/payments/inquiry';

  /// TODO(bankima-docs): گردش حساب در بازهٔ تاریخ. `{accountId}` جایگزین می‌شود.
  static const accountStatement = '/v1/accounts/{accountId}/statement';

  /// TODO(bankima-docs): اطلاعات اقساط تسهیلات بانکیما (نه اقساط داخلی صندوق).
  static const installmentInfo = '/v1/loans/{loanId}/installments';

  /// TODO(bankima-docs): تولید لینک پرداخت اینترنتی (IPG / payment-link).
  static const paymentLink = '/v1/payments/links';

  /// TODO(bankima-docs): موجودی لحظه‌ای حساب.
  static const balance = '/v1/accounts/{accountId}/balance';

  /// TODO(bankima-docs): انتقال پایا.
  static const paya = '/v1/payments/paya';

  /// TODO(bankima-docs): انتقال ساتنا.
  static const satna = '/v1/payments/satna';

  /// TODO(bankima-docs): انتقال آنی پل.
  static const pol = '/v1/payments/pol';

  /// TODO(bankima-docs): استعلام شبا.
  static const ibanInquiry = '/v1/iban/inquiry';

  static String interpolate(String path, Map<String, String> params) {
    var out = path;
    for (final e in params.entries) {
      out = out.replaceAll('{${e.key}}', Uri.encodeComponent(e.value));
    }
    return out;
  }

  static String forRail(String rail) => switch (rail) {
        'satna' => satna,
        'pol' => pol,
        _ => paya,
      };
}
