import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../../core/di/locator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/finance_services.dart';
import '../../blocs/app_blocs.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, this.installmentId});
  final String? installmentId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final amount = TextEditingController();
  final tracking = TextEditingController();
  DateTime occurred = DateTime.now();
  TransactionType type = TransactionType.sharePayment;
  String? receipt;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.installmentId != null) {
      type = TransactionType.installmentPayment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeCubit>().state;
    final inst = home.installments.where((i) => i.id == widget.installmentId).firstOrNull;
    if (inst != null && amount.text.isEmpty) {
      amount.text = inst.amount.toString();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت پرداخت')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('کد پیگیری کارت‌به‌کارت را وارد کنید. مدیر پس از دیدن فیش، پرداخت را تأیید می‌کند.', style: TextStyle(color: AppColors.muted, height: 1.7)),
          const SizedBox(height: 16),
          DropdownButtonFormField<TransactionType>(
            initialValue: type,
            items: const [
              DropdownMenuItem(value: TransactionType.sharePayment, child: Text('پرداخت سهم')),
              DropdownMenuItem(value: TransactionType.installmentPayment, child: Text('پرداخت قسط')),
            ],
            onChanged: (v) => setState(() => type = v ?? type),
            decoration: const InputDecoration(labelText: 'نوع'),
          ),
          const SizedBox(height: 12),
          PersianNumberField(controller: amount, label: 'مبلغ (تومان)'),
          const SizedBox(height: 12),
          PersianNumberField(controller: tracking, label: 'کد پیگیری'),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('تاریخ واریز'),
            subtitle: Text(jalaliDate(occurred)),
            trailing: const Icon(Icons.calendar_month_outlined),
            onTap: () async {
              final picked = await showPersianDatePicker(
                context: context,
                initialDate: Jalali.fromDateTime(occurred),
                firstDate: Jalali(1390, 1),
                lastDate: Jalali.now(),
              );
              if (picked != null) setState(() => occurred = picked.toDateTime());
            },
          ),
          OutlinedButton.icon(
            onPressed: () async {
              final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (file != null) setState(() => receipt = file.path);
            },
            icon: const Icon(Icons.attach_file),
            label: Text(receipt == null ? 'پیوست فیش (اختیاری)' : 'فیش انتخاب شد'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: busy
                ? null
                : () async {
                    final a = Validators.parseAmount(amount.text);
                    final err = Validators.trackingCode(tracking.text) ?? Validators.amount(amount.text);
                    if (err != null || a == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? 'مبلغ نامعتبر')));
                      return;
                    }
                    setState(() => busy = true);
                    final res = await sl<TransactionRepository>().submit(SubmitPaymentInput(
                      amount: a,
                      occurredAt: occurred,
                      trackingCode: Validators.toEnglishDigits(tracking.text).trim(),
                      type: type,
                      receiptPath: receipt,
                      relatedInstallmentId: widget.installmentId ?? inst?.id,
                    ));
                    if (!context.mounted) return;
                    setState(() => busy = false);
                    res.when(
                      ok: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت شد و منتظر تأیید مدیر است')));
                        context.go('/home');
                      },
                      err: (m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))),
                    );
                  },
            child: const Text('ارسال برای تأیید مدیر'),
          ),
        ],
      ),
    );
  }
}

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('وام و اقساط')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/loan-request'),
        label: const Text('درخواست وام'),
        icon: const Icon(Icons.add),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.isAdmin && state.requestedLoans.isNotEmpty) ...[
                const SectionHeader('درخواست‌های جدید'),
                ...state.requestedLoans.map((l) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('${l.memberName} — ${toman(l.amount)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('${faNum(l.termMonths)} ماه • ${l.reason}'),
                            const SizedBox(height: 8),
                            Row(children: [
                              Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.success), onPressed: () => context.read<HomeCubit>().decideLoan(l.id, true), child: const Text('تأیید'))),
                              const SizedBox(width: 8),
                              Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.danger), onPressed: () => context.read<HomeCubit>().decideLoan(l.id, false, note: 'رد مدیر'), child: const Text('رد'))),
                            ]),
                          ],
                        ),
                      ),
                    )),
              ],
              const SectionHeader('وام‌ها'),
              ...state.loans.map((l) => Card(
                    child: ListTile(
                      title: Text(l.memberName),
                      subtitle: Text('${toman(l.amount)} • ${l.status.fa}'),
                      trailing: StatusChip(
                        label: l.status.fa,
                        tone: l.status == LoanStatus.active ? ChipTone.info : ChipTone.neutral,
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class LoanRequestScreen extends StatefulWidget {
  const LoanRequestScreen({super.key});
  @override
  State<LoanRequestScreen> createState() => _LoanRequestScreenState();
}

class _LoanRequestScreenState extends State<LoanRequestScreen> {
  final amount = TextEditingController();
  final reason = TextEditingController();
  int months = 6;
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final fund = context.watch<HomeCubit>().state.fund;
    final preview = Validators.parseAmount(amount.text);
    InstallmentPlan? plan;
    if (preview != null && fund != null) {
      try {
        plan = sl<InstallmentCalculator>().plan(principal: preview, termMonths: months, start: DateTime.now(), feeRate: fund.loanAdminFeeRate, periodDays: fund.paymentPeriodDays);
      } catch (_) {}
    }
    return Scaffold(
      appBar: AppBar(title: const Text('درخواست وام')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('وام قرض‌الحسنه است. ۲٪ هزینه اداری صندوق روی اقساط سرشکن می‌شود و بهره بانکی نیست.', style: TextStyle(color: AppColors.muted, height: 1.7)),
          const SizedBox(height: 16),
          PersianNumberField(controller: amount, label: 'مبلغ درخواستی (تومان)', onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          Text('مدت: ${faNum(months)} ماه'),
          Slider(value: months.toDouble(), min: 3, max: 24, divisions: 21, onChanged: (v) => setState(() => months = v.round())),
          TextField(controller: reason, maxLines: 3, decoration: const InputDecoration(labelText: 'دلیل')),
          if (plan != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('قسط تقریبی: ${toman(plan.items.first.amount)}'),
                  Text('هزینه اداری صندوق: ${toman(plan.fee)}'),
                  Text('جمع بازپرداخت: ${toman(plan.total)}'),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: busy
                ? null
                : () async {
                    final a = Validators.parseAmount(amount.text);
                    if (a == null || reason.text.trim().isEmpty) return;
                    setState(() => busy = true);
                    final res = await sl<LoanRepository>().requestLoan(amount: a, termMonths: months, reason: reason.text.trim());
                    if (!context.mounted) return;
                    setState(() => busy = false);
                    res.when(
                      ok: (_) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('درخواست برای مدیر ارسال شد')));
                        context.pop();
                      },
                      err: (m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m))),
                    );
                  },
            child: const Text('ارسال درخواست'),
          ),
        ],
      ),
    );
  }
}
