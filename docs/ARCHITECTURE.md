# معماری پولاد

## لایه‌ها

```
presentation (Cubit + GoRouter + RTL screens)
        ↓
domain (entities, eligibility, installment & fee math)
        ↓
data (Freezed models + DemoStore | Firebase + Cloud Functions)
        ↓
local cache (Hive JSON) + session (shared_preferences)
```

Online-first: هر repository اول شبکه/منبع زنده را می‌خواند و نتیجه را در Hive می‌نویسد. اگر شبکه قطع باشد، آخرین کش با بنر زرد نمایش داده می‌شود — اپ آفلاین-اول نیست و صف عملیات مالی آفلاین ندارد.

## مدل‌های Firestore

قرارداد داده در `lib/data/models/` با Freezed و json_serializable تعریف شده است (`User`, `Fund`, `Transaction`, `Loan`, `Installment`, `Draw`, `Fee`). تبدیل سند با extensionهای `DocumentSnapshot.toUser()` / `model.toFirestore()` انجام می‌شود. Enum وضعیت‌ها مقدار سیم (`pending_approval` و مشابه) و `displayName` فارسی دارند.

## نقش‌ها

- `admin`: تأیید تراکنش، اعضا، وام، قرعه، گزارش، تنظیمات، صورتحساب
- `member`: مشاهدهٔ وضعیت خودش و ثبت پرداخت pending

اولین سازندهٔ صندوق مدیر است. بقیه با کد دعوت عضو می‌شوند.

## جریان پول

1. عضو پرداخت را با کد پیگیری ثبت می‌کند → `pending`
2. مدیر تأیید می‌کند → موجودی صندوق و سهم/بدهی عضو به‌روز می‌شود
3. Cloud Function برای مدیر `service_invoices` را افزایش می‌دهد
4. عضو همان مبلغ کامل را در صندوق می‌بیند؛ هیچ کسر کارمزدی روی پرداخت عضو نیست

## وام

جدول اقساط = اصل ÷ مدت + سرشکن ۲٪ هزینه اداری صندوق. این رقم ربا/بهره بانکی نیست و در UI به‌صراحت توضیح داده می‌شود.
