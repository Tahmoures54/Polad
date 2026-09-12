import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/loans/installment_tracker_cubit.dart';
import '../home/member_widgets.dart';

/// پیگیری اقساط همهٔ اعضا برای مدیر: فیلتر وضعیت و یادآوری دستی.
class AdminInstallmentsScreen extends StatelessWidget {
  const AdminInstallmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InstallmentTrackerCubit(),
      child: const _AdminInstallmentsView(),
    );
  }
}

class _AdminInstallmentsView extends StatelessWidget {
  const _AdminInstallmentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('پیگیری اقساط')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, home) {
          return BlocBuilder<InstallmentTrackerCubit, InstallmentTrackerState>(
            builder: (context, dash) {
              final cubit = context.read<InstallmentTrackerCubit>();
              final items = cubit.filtered(home);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Wrap(
                      spacing: 8,
                      children: AdminInstFilter.values.map((f) {
                        final selected = dash.filter == f;
                        return ChoiceChip(
                          label: Text(f.label),
                          selected: selected,
                          selectedColor: AppColors.navy,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : AppColors.navy,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) => cubit.setFilter(f),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.navy,
                      onRefresh: () => context.read<HomeCubit>().refresh(),
                      child: items.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(height: 80),
                                EmptyView(
                                  title: 'قسطی در این فیلتر نیست',
                                  subtitle: 'پس از تأیید وام، اقساط همهٔ اعضا اینجا دیده می‌شود.',
                                  icon: Icons.event_available_outlined,
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: items.length,
                              itemBuilder: (_, i) {
                                final item = items[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: MemberInstallmentCard(
                                    item: item,
                                    memberName: cubit.memberName(home, item.memberId),
                                    onRemind: () => context.read<HomeCubit>().remindInstallment(item),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
