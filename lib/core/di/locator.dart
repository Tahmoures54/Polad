import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../../data/demo/demo_backend.dart';
import '../../data/firebase/firebase_data.dart';
import '../../data/firebase/firebase_repos.dart';
import '../../data/local/cache_store.dart';
import '../../data/payments/bankima_client.dart';
import '../../data/sms/bank_sms_parser.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/services/finance_services.dart';
import '../../firebase_options.dart';

final sl = GetIt.instance;

Future<void> setupLocator({CacheStore? cache}) async {
  final store = cache ?? await CacheStore.init();
  sl.registerSingleton<CacheStore>(store);
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
    sl.registerSingleton<AuthRepository>(FirebaseAuthRepository(auth, db));
    sl.registerSingleton<FundRepository>(FirebaseFundRepository(db, auth, fn));
    sl.registerSingleton<TransactionRepository>(FirebaseTransactionRepository(db, auth, fn, storage));
    sl.registerSingleton<LoanRepository>(FirebaseLoanRepository(db, fn));
    sl.registerSingleton<DrawRepository>(FirebaseDrawRepository(db, fn));
    sl.registerSingleton<BillingRepository>(FirebaseBillingRepository(db, fn));
    sl.registerSingleton<PaymentGateway>(FirebasePaymentGateway(fn));
    sl.registerSingleton<ReportRepository>(FirebaseReportRepository(db));
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
  }
}
