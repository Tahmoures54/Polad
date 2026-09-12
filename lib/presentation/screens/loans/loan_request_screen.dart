import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/loans/loan_request_cubit.dart';
import '../../screens/auth/auth_widgets.dart';
import 'loan_widgets.dart';

/// فرم درخواست وام عضو: مبلغ، تعداد اقساط، دلیل، پیش‌نمایش ۲٪.
class LoanRequestScreen extends StatelessWidget {
  const LoanRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoanRequestCubit(),
      child: const _LoanRequestView(),
    );
  }
}

class _LoanRequestView extends StatefulWidget {
  const _LoanRequestView();

  @override
  State<_LoanRequestView> createState() => _LoanRequestViewState();
}

class _LoanRequestViewState extends State<_LoanRequestView> {
  late final TextEditingController _amount;
  late final TextEditingController _reason;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    _reason = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoanRequestCubit, LoanRequestState>(
      listenWhen: (p, c) => p.error != c.error || p.success != c.success,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('درخواست برای مدیر ارسال شد')),
          );
          context.pop();
        }
      },
      builder: (context, state) {
        final home = context.watch<HomeCubit>().state;
        final cubit = context.read<LoanRequestCubit>();
        final plan = cubit.previewOf(home.fund);
        final deny = cubit.denyReasonOf(home);
        return Scaffold(
          appBar: AppBar(title: const Text('درخواست وام')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'وام صندوق قرض‌الحسنه است. کارمزد اداری ${cubit.feeLabel(home.fund)} روی اقساط سرشکن می‌شود و بهره بانکی نیست.',
                style: const TextStyle(color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 16),
              PersianNumberField(
                controller: _amount,
                label: 'مبلغ درخواستی (تومان)',
                hint: '۲۰٬۰۰۰٬۰۰۰',
                inputFormatters: [PersianAmountFormatter()],
                onChanged: cubit.amountChanged,
              ),
              if (state.amountError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(state.amountError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
              const SizedBox(height: 16),
              Text('تعداد اقساط: ${faNum(state.months)} ماه'),
              Slider(
                value: state.months.toDouble(),
                min: 3,
                max: 24,
                divisions: 21,
                label: faNum(state.months),
                onChanged: (v) => cubit.monthsChanged(v.round()),
              ),
              TextField(
                controller: _reason,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'دلیل درخواست',
                  errorText: state.reasonError,
                ),
                onChanged: cubit.reasonChanged,
              ),
              if (plan != null) ...[
                const SizedBox(height: 16),
                InstallmentPlanCard(plan: plan),
              ],
              if (deny != null) ...[
                const SizedBox(height: 12),
                Text(deny, style: const TextStyle(color: AppColors.warning, height: 1.5)),
              ],
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: 'ارسال درخواست',
                busy: state.busy,
                onPressed: () => cubit.submit(home),
              ),
            ],
          ),
        );
      },
    );
  }
}
