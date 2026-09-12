import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/sms/bank_sms_parser.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';
import '../../blocs/app_blocs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController name;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: sl<AuthRepository>().currentUser?.displayName ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRepository>().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('پروفایل')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: PoladLogo(size: 72)),
          const SizedBox(height: 16),
          TextField(controller: name, decoration: const InputDecoration(labelText: 'نام')),
          const SizedBox(height: 8),
          Text('موبایل ${iranianPhonePretty(user?.phone ?? '')}', style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              await sl<AuthRepository>().updateProfile(displayName: name.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ذخیره شد')));
              }
            },
            child: const Text('ذخیره'),
          ),
          const SizedBox(height: 24),
          const Text('تغییر صندوق فعال', style: TextStyle(fontWeight: FontWeight.w700)),
          FutureBuilder(
            future: sl<FundRepository>().myFunds(),
            builder: (context, snap) {
              final funds = snap.data ?? const [];
              return Column(
                children: funds
                    .map(
                      (f) => ListTile(
                        title: Text(f.name),
                        selected: f.id == user?.activeFundId,
                        trailing: f.id == user?.activeFundId ? const Icon(Icons.check, color: AppColors.navy) : null,
                        onTap: () async {
                          await sl<FundRepository>().setActiveFund(f.id);
                          if (context.mounted) context.go('/boot');
                        },
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FundSettingsScreen extends StatefulWidget {
  const FundSettingsScreen({super.key});
  @override
  State<FundSettingsScreen> createState() => _FundSettingsScreenState();
}

class _FundSettingsScreenState extends State<FundSettingsScreen> {
  final share = TextEditingController();
  final charter = TextEditingController();
  double? fee;

  @override
  Widget build(BuildContext context) {
    final fund = context.watch<HomeCubit>().state.fund;
    if (fund == null) return const Scaffold(body: LoadingView());
    share.text = share.text.isEmpty ? fund.shareAmount.toString() : share.text;
    charter.text = charter.text.isEmpty ? (fund.charterText ?? '') : charter.text;
    fee ??= fund.serviceFeeRate;
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات صندوق')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PersianNumberField(controller: share, label: 'مبلغ سهم (تومان)'),
          const SizedBox(height: 12),
          Text('نرخ هزینه خدمات نرم‌افزاری مدیر: ${percentFa(fee!)}'),
          Slider(value: fee!, min: 0.005, max: 0.01, divisions: 5, onChanged: (v) => setState(() => fee = v)),
          TextField(controller: charter, maxLines: 5, decoration: const InputDecoration(labelText: 'اساسنامه')),
          const SizedBox(height: 16),
          const Text(
            'کارمزد هرگز از تراکنش عضو کم نمی‌شود. صورتحساب ماهانه برای مدیر صادر می‌گردد.',
            style: TextStyle(color: AppColors.muted, height: 1.7, fontSize: 13),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final amount = Validators.parseAmount(share.text);
              if (amount == null) return;
              context.read<HomeCubit>().updateFund(fund.copyWith(shareAmount: amount, serviceFeeRate: fee, charterText: charter.text.trim()));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ذخیره شد')));
            },
            child: const Text('ذخیره تنظیمات'),
          ),
        ],
      ),
    );
  }
}

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صورتحساب خدمات')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.invoices.isEmpty) {
            return const EmptyView(title: 'صورتحسابی نیست', subtitle: 'پس از تأیید تراکنش‌ها، هزینه خدمات نرم‌افزاری اینجا جمع می‌شود.');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'این مبلغ «هزینه خدمات نرم‌افزاری پولاد» است و مطابق بخشنامه شاپرک از عضو صندوق گرفته نمی‌شود.',
                style: TextStyle(color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 12),
              ...state.invoices.map((i) => Card(
                    child: ListTile(
                      title: Text('${faNum(i.year)}/${faNum(i.month.toString().padLeft(2, '0'))}'),
                      subtitle: Text('حجم ${toman(i.transactionVolume)} • نرخ ${percentFa(i.rate)}\n${i.note}', maxLines: 4),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(toman(i.feeAmount), style: const TextStyle(fontFamily: 'VazirmatnFD', fontWeight: FontWeight.w700)),
                          StatusChip(
                            label: i.status == InvoiceStatus.paid ? 'پرداخت شده' : 'جاری',
                            tone: i.status == InvoiceStatus.paid ? ChipTone.success : ChipTone.warning,
                          ),
                        ],
                      ),
                      onTap: i.status == InvoiceStatus.paid
                          ? null
                          : () async {
                              await sl<PaymentGateway>().startSoftwareFeePayment(invoiceId: i.id, amountToman: i.feeAmount);
                              await sl<BillingRepository>().markPaid(i.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('در حالت آزمایشی به‌عنوان پرداخت‌شده ثبت شد. در تولید از بانکیما استفاده می‌شود.')));
                              }
                            },
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class SmsMatchScreen extends StatefulWidget {
  const SmsMatchScreen({super.key});
  @override
  State<SmsMatchScreen> createState() => _SmsMatchScreenState();
}

class _SmsMatchScreenState extends State<SmsMatchScreen> {
  String status = 'فقط روی اندروید مدیر، پیامک واریز بانک خوانده می‌شود.';
  List<String> lines = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پیامک بانکی')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(status, style: const TextStyle(color: AppColors.muted, height: 1.7)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              final cubit = context.read<HomeCubit>();
              final inbox = sl<SmsInbox>();
              final ok = await inbox.requestPermission();
              if (!ok) {
                setState(() => status = 'دسترسی پیامک داده نشد. می‌توانید کد پیگیری را دستی وارد کنید.');
                return;
              }
              final sms = await inbox.readRecent();
              final pending = cubit.state.pending;
              final parser = sl<BankSmsParser>();
              final out = <String>[];
              for (final s in sms) {
                final match = parser.match(sms: s, pending: pending);
                match.when(
                  ok: (tx) => out.add('تطبیق ${tx.memberName} — ${toman(tx.amount)}'),
                  err: (m) => out.add('${s.sender}: $m'),
                );
              }
              setState(() {
                lines = out;
                status = out.isEmpty ? 'پیامک قابل‌تطبیقی پیدا نشد.' : 'نتیجه تطبیق:';
              });
            },
            child: const Text('خواندن پیامک‌های اخیر'),
          ),
          const SizedBox(height: 12),
          ...lines.map((e) => ListTile(title: Text(e))),
        ],
      ),
    );
  }
}
