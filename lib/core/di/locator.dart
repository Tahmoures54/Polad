import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../network/network_retry.dart';
import '../../data/demo/demo_backend.dart';
import '../../data/firebase/firebase_data.dart';
import '../../data/firebase/firebase_repos.dart';
import '../../data/local/cache_store.dart';
import '../../data/payments/bankima_client.dart';
import '../../data/services/services.dart';
import '../../data/sms/bank_sms_parser.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/services/finance_services.dart';
import '../../firebase_options.dart';

final sl = GetIt.instance;

Future<void> setupLocator({CacheStore? cache}) async {
  final store = cache ?? await CacheStore.init();
  sl.registerSingleton<CacheStore>(store);
  sl.registerSingleton<NetworkRetry>(NetworkRetry.standard);
  sl.registerLazySingleton<BankSmsParser>(BankSmsParser.new);
  sl.registerLazySingleton<InstallmentCalculator>(InstallmentCalculator.new);
  sl.registerLazySingleton<FeeCalculator>(FeeCalculator.new);
  sl.registerLazySingleton<LoanEligibility>(LoanEligibility.new);
  sl.registerLazySingleton<BankimaClient>(BankimaClient.new);
  sl.registerLazySingleton<SmsInbox>(MethodChannelSmsInbox.new);

  if (AppConfig.useFirebase) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;
    final fn = FirebaseCallable(FirebaseFunctions.instance);
    final storage = FirebaseStorage.instance;
    final retry = sl<NetworkRetry>();

    sl.registerSingleton<AuthRepository>(FirebaseAuthRepository(auth, db));
    sl.registerSingleton<FundRepository>(FirebaseFundRepository(db, auth, fn));
    sl.registerSingleton<TransactionRepository>(
      FirebaseTransactionRepository(db, auth, fn, storage),
    );
    sl.registerSingleton<LoanRepository>(FirebaseLoanRepository(db, fn));
    sl.registerSingleton<DrawRepository>(FirebaseDrawRepository(db, fn));
    sl.registerSingleton<BillingRepository>(FirebaseBillingRepository(db, fn));
    sl.registerSingleton<PaymentGateway>(FirebasePaymentGateway(fn));
    sl.registerSingleton<ReportRepository>(FirebaseReportRepository(db));

    sl.registerSingleton<FirestoreService>(FirebaseFirestoreService(db, retry: retry));
    sl.registerSingleton<FunctionsService>(
      FirebaseFunctionsService(FirebaseFunctions.instance, retry: retry),
    );
    sl.registerSingleton<StorageService>(FirebaseStorageService(storage, retry: retry));
    sl.registerSingleton<AuthService>(
      FirebaseAuthService(
        auth,
        (uid) => sl<FirestoreService>().getUser(uid),
        (user) => sl<FirestoreService>().upsertUser(user),
        ({required uid, required role, fundId}) =>
            sl<FunctionsService>().setCustomClaims(uid: uid, role: role, fundId: fundId),
        retry: retry,
      ),
    );
    sl.registerSingleton<NotificationService>(
      FirebaseNotificationService(
        FirebaseMessaging.instance,
        FlutterLocalNotificationsPlugin(),
        (token) async {
          final uid = auth.currentUser?.uid;
          if (uid == null) return;
          await db.collection(CollectionPaths.users).doc(uid).set(
            {'fcmToken': token},
            SetOptions(merge: true),
          );
        },
        retry: retry,
      ),
    );
  } else {
    final demo = DemoStore(store);
    await demo.load();
    sl.registerSingleton<DemoStore>(demo);
    sl.registerSingleton<AuthRepository>(DemoAuthRepository(demo));
    sl.registerSingleton<FundRepository>(DemoFundRepository(demo));
    sl.registerSingleton<TransactionRepository>(DemoTransactionRepository(demo));
    sl.registerSingleton<LoanRepository>(DemoLoanRepository(demo));
    sl.registerSingleton<DrawRepository>(DemoDrawRepository(demo));
    sl.registerSingleton<BillingRepository>(DemoBillingRepository(demo));
    sl.registerSingleton<ReportRepository>(DemoReportRepository(demo));
    sl.registerSingleton<PaymentGateway>(DemoPaymentGateway());

    sl.registerSingleton<FirestoreService>(InMemoryFirestoreService());
    sl.registerSingleton<FunctionsService>(DemoFunctionsService());
    sl.registerSingleton<StorageService>(DemoStorageService());
    sl.registerSingleton<AuthService>(DemoAuthService(demo));
    sl.registerSingleton<NotificationService>(DemoNotificationService());
  }
}
