import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/enums.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/payments/bankima_cubit.dart';

/// ابزارهای بانکیما برای مدیر صندوق.
///
/// استعلام و لینک پرداخت موجودی صندوق را عوض نمی‌کنند؛ تأیید تراکنش عضو
/// فقط از صف انتظار انجام می‌شود.
class BankimaToolsScreen extends StatelessWidget {
  const BankimaToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BankimaCubit(),
      child: const _BankimaView(),
    );
  }
}

class _BankimaView extends StatefulWidget {
  const _BankimaView();

  @override
  State<_BankimaView> createState() => _BankimaViewState();
}

class _BankimaViewState extends State<_BankimaView> {
  final account = TextEditingController();
  final receipt = TextEditingController();
  final loan = TextEditingController();
  final iban = TextEditingController();
  final amount = TextEditingController();
  final desc = TextEditingController(text: 'انتقال صندوق خانوادگی پولاد');
  BankTransferRail rail = BankTransferRail.paya;

  @override
  void initState() {
    super.initState();
    final fund = context.read<HomeCubit>().state.fund;
    account.text = fund?.bankAccount ?? '';
    iban.text = fund?.bankIban ?? '';
  }

  @override
  void dispose() {
    account.dispose();
    receipt.dispose();
    loan.dispose();
    iban.dispose();
    amount.dispose();
    desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeCubit>().state;
    return BlocConsumer<BankimaCubit, BankimaUiState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        } else if (state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<BankimaCubit>();
        return Scaffold(
          appBar: AppBar(title: const Text('بانکیما')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'باهمتا تعطیل است. همهٔ استعلام‌ها و انتقال‌ها از طریق بانکیما انجام می‌شود. نتیجهٔ بانکی هرگز به‌معنای تأیید خودکار تراکنش صندوق نیست.',
                style: TextStyle(color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 16),
              TextField(controller: account, decoration: const InputDecoration(labelText: 'شناسه حساب')),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: state.busy ? null : () => cubit.loadBalance(account.text.trim()),
                child: const Text('موجودی'),
              ),
              if (state.balance != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AmountText(state.balance!.availableToman),
                ),
              const Divider(height: 32),
              TextField(controller: receipt, decoration: const InputDecoration(labelText: 'کد پیگیری / رسید')),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: state.busy ? null : () => cubit.verify(receipt.text.trim()),
                child: const Text('استعلام تراکنش'),
              ),
              if (state.verified != null)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(toman(state.verified!.amountToman)),
                  subtitle: Text('وضعیت بانکی: ${state.verified!.status}'),
                ),
              const Divider(height: 32),
              OutlinedButton(
                onPressed: state.busy
                    ? null
                    : () => cubit.statement(
                          account.text.trim(),
                          DateTime.now().subtract(const Duration(days: 30)),
                          DateTime.now(),
                        ),
                child: const Text('گردش ۳۰ روز اخیر'),
              ),
              ...?state.statement?.rows.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('${r.isCredit ? 'واریز' : 'برداشت'} ${toman(r.amountToman)}'),
                  subtitle: Text('کد ${r.trackingCode} • ${jalaliDate(r.occurredAt)}'),
                ),
              ),
              const Divider(height: 32),
              TextField(controller: loan, decoration: const InputDecoration(labelText: 'شناسه تسهیلات بانکیما')),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: state.busy ? null : () => cubit.installments(loan.text.trim()),
                child: const Text('اطلاعات اقساط بانک'),
              ),
              if (state.installments != null)
                Text('مانده ${toman(state.installments!.remainingToman)} از ${toman(state.installments!.principalToman)}'),
              const Divider(height: 32),
              const Text('لینک پرداخت عضو', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              ...home.members.map(
                (m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(m.displayName),
                  subtitle: const Text('لینک با مبلغ سهم صندوق'),
                  trailing: IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: home.fund == null || state.busy
                        ? null
                        : () async {
                            await cubit.paymentLink(m.userId, home.fund!.shareAmount);
                            if (!context.mounted) return;
                            final url = context.read<BankimaCubit>().state.paymentLink?.url;
                            if (url != null) {
                              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            }
                          },
                  ),
                ),
              ),
              const Divider(height: 32),
              const Text('انتقال وجه', style: TextStyle(fontWeight: FontWeight.w700)),
              DropdownButtonFormField<BankTransferRail>(
                initialValue: rail,
                items: BankTransferRail.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.fa)))
                    .toList(),
                onChanged: (v) => setState(() => rail = v ?? rail),
                decoration: const InputDecoration(labelText: 'ریل'),
              ),
              const SizedBox(height: 8),
              TextField(controller: iban, decoration: const InputDecoration(labelText: 'شبا مقصد')),
              const SizedBox(height: 8),
              PersianNumberField(controller: amount, label: 'مبلغ (تومان)'),
              const SizedBox(height: 8),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'شرح')),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: state.busy
                    ? null
                    : () {
                        final n = Validators.parseAmount(amount.text);
                        if (n == null) return;
                        cubit.sendTransfer(
                          rail: rail,
                          iban: iban.text.trim(),
                          amountToman: n,
                          description: desc.text.trim(),
                        );
                      },
                child: const Text('ارسال انتقال'),
              ),
              if (state.busy) const Padding(padding: EdgeInsets.all(16), child: LoadingView()),
            ],
          ),
        );
      },
    );
  }
}
