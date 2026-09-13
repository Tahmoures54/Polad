# یکپارچه‌سازی بانکیما (بانک ملت)

باهمتا تعطیل است. مسیر پرداخت و استعلام رسمی، پلتفرم بانکداری باز **بانکیما** است.

مستندات کامل و sandbox پس از قرارداد همکاری روی پرتال بانکیما صادر می‌شود. این مخزن یک آداپتور پایدار دارد:

- کلاینت موبایل فقط به **Cloud Functions** حرف می‌زند.
- Functions با OAuth2 client-credentials به API بانکیما وصل می‌شود.
- مبالغ بانکی به **ریال** ارسال می‌شوند (`toman * 10`).
- اسرار (`BANKIMA_CLIENT_ID`, `BANKIMA_CLIENT_SECRET`) هرگز داخل اپ نیستند.

## سرویس‌ها (`BankimaService`)

| متد | کار | Callable |
| --- | --- | --- |
| `verifyTransaction(receiptCode)` | استعلام تراکنش | `bankimaVerifyTransaction` |
| `getAccountStatement(accountId, dateRange)` | گردش حساب | `bankimaAccountStatement` |
| `getInstallmentInfo(loanId)` | اطلاعات اقساط تسهیلات بانک | `bankimaInstallmentInfo` |
| `createPaymentLink(memberId, amount)` | لینک پرداخت | `bankimaCreatePaymentLink` |
| `getBalance(accountId)` | موجودی | `bankimaGetBalance` |
| `transfer(paya/satna/pol)` | انتقال وجه | `bankimaTransfer` |

استعلام موفق بانکی **تأیید صندوق نیست**. تراکنش عضو تا تصمیم مدیر در `pending_approval` می‌ماند.

## TODO مستندات رسمی پرتال

مسیرهای HTTP در `lib/data/payments/bankima_paths.dart` و `functions/src/bankima.js` با برچسب `TODO(bankima-docs)` مشخص شده‌اند. پس از دریافت PDF شریک:

1. `BANKIMA_BASE_URL` و مسیر OAuth2 (`/oauth/token`)
2. نام فیلد توکن و `expires_in`
3. مسیر استعلام رسید (`/v1/payments/inquiry`)
4. مسیر گردش و موجودی حساب
5. مسیر لینک پرداخت / IPG
6. مسیرهای پایا، ساتنا، پل و محدودیت مبلغ هر ریل
7. قرارداد فیلد مبلغ (ریال در برابر تومان)

تا آن زمان، Functions در نبود credential پاسخ دمو/خالی برمی‌گرداند و ثبت دستی + پیامک + تأیید مدیر کامل کار می‌کند.

## خطا و retry

- Dart: `NetworkRetry` (۳ تلاش نمایی) فقط روی خطاهای شبکه/۵xx.
- Functions: `withRetry` در `bankima.js` (۳ تلاش، ۴۲۹ و ۵xx).
- ۴۰۱/۴۰۳ هرگز retry نمی‌شوند.

## پیامک بانکی مدیر

`SmsParserService` پیامک ملت، ملی، صادرات، پاسارگاد، سامان و پارسیان را می‌خواند، مبلغ/تاریخ/کد پیگیری را استخراج می‌کند و در صورت نبود تراکنش متناظر یک **پیشنهاد** با `source: smsMatch` و وضعیت `pending_approval` می‌سازد.

**تأیید خودکار مطلقاً ممنوع است.**
