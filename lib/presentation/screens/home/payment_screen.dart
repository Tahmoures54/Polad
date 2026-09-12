import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/enums.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/member/payment_cubit.dart';
import '../auth/auth_widgets.dart';

/// فرم ثبت پرداخت سهم یا قسط؛ نتیجه با وضعیت `pending_approval` ذخیره می‌شود.
class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key, this.installmentId});

  final String? installmentId;

  @override
  Widget build(BuildContext context) {
    final home = context.read<HomeCubit>().state;
    final inst = home.installments.where((i) => i.id == installmentId).firstOrNull;
    return BlocProvider(
      create: (_) => PaymentCubit(
        installmentId: installmentId,
        presetAmount: inst?.amount,
      ),
      child: const _PaymentView(),
    );
  }
}

class _PaymentView extends StatefulWidget {
  const _PaymentView();

  @override
  State<_PaymentView> createState() => _PaymentViewState();
}

class _PaymentViewState extends State<_PaymentView> {
  late final TextEditingController _amount;
  late final TextEditingController _tracking;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<PaymentCubit>();
    final preset = cubit.state.amountText;
    final grouped = preset.isEmpty ? '' : groupedFaAmount(int.tryParse(preset) ?? 0);
    _amount = TextEditingController(text: grouped.isEmpty ? preset : grouped);
    _tracking = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    _tracking.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentFormState>(
      listenWhen: (p, c) => p.error != c.error || p.success != c.success,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
        }
        if (state.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ثبت شد و منتظر تأیید مدیر است')),
          );
          context.read<HomeCubit>().refresh().whenComplete(() {
            if (context.mounted) context.go('/home');
          });
        }
      },
      builder: (context, state) {
        final cubit = context.read<PaymentCubit>();
        return Scaffold(
          appBar: AppBar(title: const Text('ثبت پرداخت')),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'کد پیگیری کارت‌به‌کارت را وارد کنید. تا تأیید مدیر، وضعیت «در انتظار تأیید» می‌ماند و از موجودی عضو کم نمی‌شود.',
                style: TextStyle(color: AppColors.muted, height: 1.7),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                initialValue: state.type,
                items: const [
                  DropdownMenuItem(value: TransactionType.sharePayment, child: Text('پرداخت سهم')),
                  DropdownMenuItem(value: TransactionType.installmentPayment, child: Text('پرداخت قسط')),
                ],
                onChanged: (v) => cubit.typeChanged(v ?? state.type),
                decoration: const InputDecoration(labelText: 'نوع'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [PersianAmountFormatter()],
                style: const TextStyle(fontFamily: 'VazirmatnFD', fontSize: 20, letterSpacing: 0.6),
                decoration: InputDecoration(
                  labelText: 'مبلغ (تومان)',
                  hintText: '۵٬۰۰۰٬۰۰۰',
                  errorText: state.amountError,
                  prefixIcon: const Icon(Icons.payments_outlined, color: AppColors.navy),
                ),
                onChanged: cubit.amountChanged,
              ),
              const SizedBox(height: 12),
              PersianNumberField(
                controller: _tracking,
                label: 'کد پیگیری',
                hint: '۱۲۳۴۵۶۷۸۹',
                validator: Validators.trackingCode,
                onChanged: cubit.trackingChanged,
              ),
              if (state.trackingError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 8),
                  child: Text(state.trackingError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('تاریخ واریز'),
                subtitle: Text(jalaliDate(state.date)),
                trailing: const Icon(Icons.calendar_month_outlined, color: AppColors.navy),
                onTap: () async {
                  final picked = await showPersianDatePicker(
                    context: context,
                    initialDate: Jalali.fromDateTime(state.date),
                    firstDate: Jalali(1390, 1),
                    lastDate: Jalali.now(),
                  );
                  if (picked != null) cubit.dateChanged(picked.toDateTime());
                },
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
                  cubit.receiptPicked(file?.path);
                },
                icon: const Icon(Icons.attach_file),
                label: Text(state.receiptPath == null ? 'پیوست فیش (اختیاری)' : 'فیش انتخاب شد'),
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: 'ارسال برای تأیید مدیر',
                busy: state.busy,
                onPressed: cubit.submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
