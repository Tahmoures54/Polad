# استقرار تولید

1. `firebase login` و `firebase use --add`
2. `flutterfire configure --project <id>`
3. قوانین و توابع: `firebase deploy --only firestore,storage,functions`
4. اسرار: `BANKIMA_BASE_URL` و `BANKIMA_CLIENT_SECRET` فقط در Functions
5. Phone Auth را در کنسول با هش SHA-1/SHA-256 اپ اندروید و APNs آی‌اواس فعال کنید
6. بیلد:

```
flutter build apk --release --dart-define=POLAD_DEMO=false --dart-define=POLAD_FIREBASE=true
flutter build ipa --dart-define=POLAD_DEMO=false --dart-define=POLAD_FIREBASE=true
```

کلید امضای اندروید را در `android/key.properties` بگذارید و هرگز commit نکنید.
