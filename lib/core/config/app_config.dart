import '../brand/polad_voice.dart';

/// Runtime flavor. Production builds must pass:
/// `--dart-define=POLAD_DEMO=false --dart-define=POLAD_FIREBASE=true`
class AppConfig {
  static const demoMode = bool.fromEnvironment(
    'POLAD_DEMO',
    defaultValue: true,
  );

  static const firebaseEnabled = bool.fromEnvironment(
    'POLAD_FIREBASE',
    defaultValue: false,
  );

  static const appName = 'پولاد';
  static const legalName = 'صندوق خانوادگی پولاد';
  static const tagline = PoladVoice.tagline;
  static const supportPhone = '02100000000';
  static const inviteHost = 'https://polad.app';
  static const inviteScheme = 'polad';

  /// Bankima (Bank Mellat Open Banking). Secrets live only in Cloud Functions.
  static const bankimaBaseUrl = String.fromEnvironment(
    'BANKIMA_BASE_URL',
    defaultValue: 'https://api.bankima.ir',
  );

  static bool get useFirebase => firebaseEnabled && !demoMode;
}
