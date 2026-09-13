import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/enums.dart';
import '../../../domain/services/finance_services.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/billing/billing_cubit.dart';
import '../auth/auth_widgets.dart';

/// صورتحساب کارمزد نرم‌افزار: خط تراکنش، جمع ماه، پرداخت — فقط بدهی مدیر.
class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BillingCubit(),
      child: const _BillingView(),
    );
  }
}

class _BillingView extends StatelessWidget {
  const _BillingView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, home) {
        return BlocBuilder<BillingCubit, BillingUiState>(
          builder: (context, ui) {
            final cubit = context.read<BillingCubit>();
            final snap = cubit.snapshot(home);
            final j = Jalali.fromDateTime(ui.cursor);
            return Scaffold(
              appBar: AppBar(
                title: const Text('صورتحساب کارمزد'),
                actions: [
                  IconButton(
                    tooltip: 'یادآوری پرداخت',
                    onPressed: () => context.read<HomeCubit>().remindSoftwareFee(),
                    icon: const Icon(Icons.notifications_active_outlined),
                  ),
                  IconButton(
                    tooltip: 'تنظیم نرخ',
                    onPressed: () => context.push('/fee-rate'),
                    icon: const Icon(Icons.percent),
                  ),
                ],
              ),
              body: RefreshIndicator(
                color: AppColors.navy,
                onRefresh: () => context.read<HomeCubit>().refresh(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(RevenueService.shaparakGuide, style: const TextStyle(color: AppColors.muted, height: 1.7)),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('ماه صورتحساب'),
                      subtitle: Text('${faNum(j.year)}/${faNum(j.month.toString().padLeft(2, '0'))}'),
                      trailing: const Icon(Icons.calendar_month_outlined, color: AppColors.navy),
                      onTap: () async {
                        final picked = await showPersianDatePicker(
                          context: context,
                          initialDate: j,
                          firstDate: Jalali(1400, 1),
                          lastDate: Jalali.now(),
                        );
                        if (picked != null) cubit.setMonth(picked.toDateTime());
                      },
                    ),
                    if (snap.charityZeroFee)
                      const Card(
                        color: AppColors.successSoft,
                        child: ListTile(
                          leading: Icon(Icons.volunteer_activism, color: AppColors.success),
                          title: Text('حالت کارمزد صفر (صندوق خیریه)'),
                          subtitle: Text('از مدیر و عضو هیچ کارمزد نرم‌افزاری گرفته نمی‌شود.'),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(child: SummaryCard(title: 'حجم تراکنش', value: snap.volume, color: AppColors.navy)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SummaryCard(
                              title: 'کارمزد مدیر ${percentFa(snap.rate)}',
                              value: snap.feeTotal,
                              color: AppColors.gold,
                              subtitle: snap.invoice?.status.fa,
                            ),
                          ),
                        ],
                      ),
                    const SectionHeader('تراکنش‌های تأییدشده این ماه'),
                    if (snap.lines.isEmpty)
                      const EmptyView(
                        title: 'تراکنش تأییدشده‌ای در این ماه نیست',
                        subtitle: 'پس از تأیید پرداخت اعضا، کارمزد هر ردیف اینجا می‌آید.',
                        icon: Icons.receipt_long_outlined,
                      )
                    else
                      ...snap.lines.map(
                        (line) => Card(
                          child: ListTile(
                            title: Text(line.tx.memberName),
                            subtitle: Text(
                              '${line.tx.type.fa} • ${jalaliDate(line.tx.occurredAt)} • ${toman(line.tx.amount)}',
                            ),
                            trailing: Text(
                              snap.charityZeroFee ? 'صفر' : toman(line.fee),
                              style: const TextStyle(fontFamily: 'VazirmatnFD', fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (snap.needsPayment && snap.invoice != null)
                      AuthPrimaryButton(
                        label: 'پرداخت ${toman(snap.feeTotal)}',
                        onPressed: () => context.read<HomeCubit>().paySoftwareFee(snap.invoice!),
                      )
                    else if (snap.charityZeroFee)
                      const Text('پرداختی برای این ماه ثبت نمی‌شود.', textAlign: TextAlign.center)
                    else if (snap.invoice?.status == InvoiceStatus.paid)
                      const Text('این ماه تسویه شده است.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.success)),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.push('/subscription'),
                      child: const Text('مدیریت اشتراک'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
