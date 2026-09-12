import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'presentation/blocs/app_blocs.dart';
import 'presentation/router/app_router.dart';

class PoladApp extends StatefulWidget {
  const PoladApp({super.key});

  @override
  State<PoladApp> createState() => _PoladAppState();
}

class _PoladAppState extends State<PoladApp> {
  late final SessionCubit _session;
  late final router = createRouter(_session);

  @override
  void initState() {
    super.initState();
    _session = SessionCubit();
  }

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _session,
      child: BlocBuilder<SessionCubit, SessionState>(
        builder: (context, session) {
          Widget app = MaterialApp.router(
            title: 'پولاد',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            locale: const Locale('fa', 'IR'),
            supportedLocales: const [Locale('fa', 'IR')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
          final user = session.user;
          final fundId = user?.activeFundId;
          if (user != null && fundId != null) {
            app = BlocProvider(
              key: ValueKey('$fundId-${user.id}'),
              create: (_) => HomeCubit(fundId: fundId, userId: user.id),
              child: app,
            );
          }
          return app;
        },
      ),
    );
  }
}
