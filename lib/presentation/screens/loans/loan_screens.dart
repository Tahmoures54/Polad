import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/app_blocs.dart';
import 'admin_loans_screen.dart';
import 'member_loans_screen.dart';

export 'admin_installments_screen.dart';
export 'admin_loans_screen.dart';
export 'loan_request_screen.dart';
export 'member_loans_screen.dart';

/// هاب وام: مدیر مدیریت می‌کند، عضو فهرست خودش را می‌بیند.
class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<HomeCubit>().state.isAdmin;
    return admin ? const AdminLoansScreen() : const MemberLoansScreen();
  }
}
