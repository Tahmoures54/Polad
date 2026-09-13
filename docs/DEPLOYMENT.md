# استقرار تولید

1. `firebase login` و `firebase use --add`
2. `flutterfire configure --project <id>`
3. توابع TypeScript: `cd functions && npm install && npm run build`
4. قوانین و توابع: `firebase deploy --only firestore,storage,functions`
5. اسرار: `BANKIMA_BASE_URL` و `BANKIMA_CLIENT_SECRET` فقط در Functions
6. Phone Auth را در کنسول با هش SHA-1/SHA-256 اپ اندروید و APNs آی‌اواس فعال کنید
7. بیلد:

```
flutter build apk --release --dart-define=POLAD_DEMO=false --dart-define=POLAD_FIREBASE=true
flutter build ipa --dart-define=POLAD_DEMO=false --dart-define=POLAD_FIREBASE=true
```

کلید امضای اندروید را در `android/key.properties` بگذارید و هرگز commit نکنید.

تست توابع: `cd functions && npm test`
