import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/sms/sms_parser_service.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/payments/bankima_cubit.dart';
import 'settings_hub_screen.dart';

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
          OutlinedButton.icon(
            onPressed: () => pickAvatar(context),
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('تغییر آواتار'),
          ),
          const SizedBox(height: 12),
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
  final period = TextEditingController();
  final charter = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final fund = context.watch<HomeCubit>().state.fund;
    if (fund == null) return const Scaffold(body: LoadingView());
    share.text = share.text.isEmpty ? fund.shareAmount.toString() : share.text;
    period.text = period.text.isEmpty ? fund.paymentPeriodDays.toString() : period.text;
    charter.text = charter.text.isEmpty ? (fund.charterText ?? '') : charter.text;
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات صندوق')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PersianNumberField(controller: share, label: 'مبلغ سهم (تومان)'),
          const SizedBox(height: 12),
          PersianNumberField(controller: period, label: 'دوره پرداخت (روز)'),
          const SizedBox(height: 12),
          TextField(controller: charter, maxLines: 5, decoration: const InputDecoration(labelText: 'اساسنامه')),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.percent, color: AppColors.navy),
            title: const Text('نرخ کارمزد نرم‌افزار'),
            subtitle: Text(fund.isCharity ? 'کارمزد صفر (خیریه)' : percentFa(fund.serviceFeeRate)),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/fee-rate'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.workspace_premium_outlined, color: AppColors.navy),
            title: const Text('اشتراک'),
            subtitle: Text(fund.tier.fa),
            trailing: const Icon(Icons.chevron_left),
            onTap: () => context.push('/subscription'),
          ),
          const SizedBox(height: 8),
          const Text(
            'کارمزد هرگز از تراکنش عضو کم نمی‌شود. صورتحساب ماهانه برای مدیر صادر می‌گردد.',
            style: TextStyle(color: AppColors.muted, height: 1.7, fontSize: 13),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final amount = Validators.parseAmount(share.text);
              final days = Validators.parseAmount(period.text);
              if (amount == null || days == null) return;
              context.read<HomeCubit>().updateFund(fund.copyWith(shareAmount: amount, paymentPeriodDays: days, charterText: charter.text.trim()));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ذخیره شد')));
            },
            child: const Text('ذخیره تنظیمات'),
          ),
        ],
      ),
    );
  }
}

class SmsMatchScreen extends StatelessWidget {
  const SmsMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SmsInboxCubit(),
      child: const _SmsMatchView(),
    );
  }
}

class _SmsMatchView extends StatelessWidget {
  const _SmsMatchView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SmsInboxCubit, SmsInboxState>(
      listenWhen: (p, c) => p.error != c.error || p.report != c.report,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.report != null) {
          context.read<HomeCubit>().refresh();
        }
      },
      builder: (context, state) {
        final home = context.watch<HomeCubit>().state;
        return Scaffold(
          appBar: AppBar(title: const Text('پیامک بانکی')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'پیامک واریز بانک‌های ملت، ملی، صادرات، پاسارگاد، سامان و پارسیان روی گوشی مدیر خوانده می‌شود و فقط به‌صورت «پیشنهاد» در صف انتظار می‌نشیند. تأیید هرگز خودکار نیست.',
                style: TextStyle(color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: state.busy
                    ? null
                    : () => context.read<SmsInboxCubit>().scan(
                          isAdmin: home.isAdmin,
                          existing: home.transactions,
                          members: home.members,
                        ),
                child: Text(state.busy ? 'در حال خواندن…' : 'خواندن پیامک‌های اخیر'),
              ),
              const SizedBox(height: 12),
              if (state.report != null)
                Text(
                  'تطبیق: ${state.report!.matchedCount}  •  پیشنهاد جدید: ${state.report!.createdCount}  •  تأیید خودکار: خیر',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              const SizedBox(height: 8),
              ...state.items.map((item) {
                final sms = item.sms;
                return Card(
                  child: ListTile(
                    title: Text('${sms.bank.fa} — ${sms.amount == null ? '—' : toman(sms.amount!)}'),
                    subtitle: Text(
                      '${item.message}\nکد ${sms.trackingCode ?? '—'} • ${jalaliDate(sms.occurredAt ?? sms.receivedAt)}',
                      style: const TextStyle(height: 1.5),
                    ),
                    isThreeLine: true,
                    trailing: StatusChip(
                      label: _kindLabel(item.kind),
                      tone: item.kind == SmsSuggestionKind.createdSuggestion
                          ? ChipTone.warning
                          : item.kind == SmsSuggestionKind.matchedPending
                              ? ChipTone.info
                              : ChipTone.neutral,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _kindLabel(SmsSuggestionKind kind) => switch (kind) {
        SmsSuggestionKind.matchedPending => 'منتظر تأیید',
        SmsSuggestionKind.createdSuggestion => 'پیشنهاد',
        SmsSuggestionKind.duplicate => 'تکراری',
        SmsSuggestionKind.ignored => 'نادیده',
      };
}
