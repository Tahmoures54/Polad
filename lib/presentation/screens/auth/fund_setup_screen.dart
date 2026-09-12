import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../data/local/cache_store.dart';
import '../../../domain/repositories/repositories.dart';

class FundSetupScreen extends StatefulWidget {
  const FundSetupScreen({super.key});
  @override
  State<FundSetupScreen> createState() => _FundSetupScreenState();
}

class _FundSetupScreenState extends State<FundSetupScreen> {
  late bool create;

  @override
  void initState() {
    super.initState();
    // نقش انتخاب‌شده در پروفایل: عضو → پیوستن با دعوت؛ مدیر → ایجاد صندوق.
    create = sl<CacheStore>().intendedRole != 'member';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صندوق شما')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('اولین کاربر صندوق، مدیر می‌شود. بقیه با کد دعوت عضو می‌شوند.', style: TextStyle(color: AppColors.muted, height: 1.7)),
          const SizedBox(height: 20),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('ایجاد صندوق'), icon: Icon(Icons.add_home_outlined)),
              ButtonSegment(value: false, label: Text('پیوستن'), icon: Icon(Icons.login)),
            ],
            selected: {create},
            onSelectionChanged: (s) => setState(() => create = s.first),
          ),
          const SizedBox(height: 24),
          if (create) const _CreateForm() else const _JoinForm(),
        ],
      ),
    );
  }
}

class _CreateForm extends StatefulWidget {
  const _CreateForm();
  @override
  State<_CreateForm> createState() => _CreateFormState();
}

class _CreateFormState extends State<_CreateForm> {
  final name = TextEditingController(text: 'صندوق خانوادگی پولاد');
  final share = TextEditingController(text: AppConstants.defaultShareToman.toString());
  final period = TextEditingController(text: '30');
  double fee = AppConstants.defaultServiceFeeRate;
  bool charity = false;
  bool busy = false;
  final iban = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'نام صندوق')),
        const SizedBox(height: 12),
        PersianNumberField(controller: share, label: 'مبلغ سهم ماهانه (تومان)'),
        const SizedBox(height: 12),
        PersianNumberField(controller: period, label: 'دوره پرداخت (روز)'),
        const SizedBox(height: 16),
        Text('هزینه خدمات نرم‌افزاری مدیر: ${(fee * 100).toStringAsFixed(1)}٪', style: const TextStyle(fontWeight: FontWeight.w600)),
        Slider(
          value: fee,
          min: 0.005,
          max: 0.01,
          divisions: 5,
          label: '${(fee * 100).toStringAsFixed(1)}٪',
          onChanged: (v) => setState(() => fee = v),
        ),
        const Text(
          'این مبلغ از عضو کسر نمی‌شود. طبق بخشنامه شاپرک، فقط به‌عنوان هزینه نرم‌افزار از مدیر دریافت می‌گردد.',
          style: TextStyle(color: AppColors.muted, fontSize: 12, height: 1.6),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('صندوق خیریه (درگاه با کارمزد صفر)'),
          value: charity,
          onChanged: (v) => setState(() => charity = v),
        ),
        TextField(controller: iban, decoration: const InputDecoration(labelText: 'شبا صندوق (اختیاری)'), textDirection: TextDirection.ltr),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: busy
              ? null
              : () async {
                  final amount = Validators.parseAmount(share.text);
                  if (amount == null) return;
                  setState(() => busy = true);
                  final res = await sl<FundRepository>().createFund(CreateFundInput(
                    name: name.text.trim(),
                    shareAmount: amount,
                    paymentPeriodDays: int.tryParse(Validators.toEnglishDigits(period.text)) ?? 30,
                    serviceFeeRate: fee,
                    bankIban: iban.text.trim().isEmpty ? null : iban.text.trim().toUpperCase(),
                    isCharity: charity,
                  ));
                  if (!context.mounted) return;
                  setState(() => busy = false);
                  res.when(
                    ok: (_) => context.go('/home'),
                    err: (m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))),
                  );
                },
          child: const Text('ایجاد صندوق و ادامه'),
        ),
      ],
    );
  }
}

class _JoinForm extends StatefulWidget {
  const _JoinForm();
  @override
  State<_JoinForm> createState() => _JoinFormState();
}

class _JoinFormState extends State<_JoinForm> {
  final code = TextEditingController();
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: code,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'کد دعوت', hintText: 'POLAD1'),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: busy
              ? null
              : () async {
                  setState(() => busy = true);
                  final res = await sl<FundRepository>().joinByInvite(code.text);
                  if (!context.mounted) return;
                  setState(() => busy = false);
                  res.when(
                    ok: (_) => context.go('/home'),
                    err: (m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))),
                  );
                },
          child: const Text('پیوستن به صندوق'),
        ),
      ],
    );
  }
}
