import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/app_blocs.dart';
import '../../blocs/member/member_dashboard_cubit.dart';
import 'member_shimmer.dart';
import 'member_widgets.dart';

/// داشبورد عضو: خلاصه سهم/بدهی/طلب، اقساط پیش‌رو، تاریخچه و ثبت پرداخت.
///
/// داده از [HomeCubit] می‌آید؛ فیلتر تاریخچه در [MemberDashboardCubit] است.
class MemberDashboard extends StatelessWidget {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MemberDashboardCubit(),
      child: const _MemberDashboardView(),
    );
  }
}

class _MemberDashboardView extends StatelessWidget {
  const _MemberDashboardView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, home) {
        if (home.loading || home.me == null) {
          return const Scaffold(body: MemberDashboardShimmer());
        }
        return BlocBuilder<MemberDashboardCubit, MemberDashboardState>(
          builder: (context, dashState) {
            final me = home.me!;
            final cubit = context.read<MemberDashboardCubit>();
            final upcoming = cubit.upcomingOf(home);
            final history = cubit.historyOf(home);
            return Scaffold(
              backgroundColor: AppColors.bg,
              body: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.navy,
                      onRefresh: () => context.read<HomeCubit>().refresh(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverAppBar(
                            pinned: true,
                            title: Text(home.fund?.name ?? 'صندوق خانوادگی پولاد'),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            sliver: SliverList.list(
                              children: [
                                Text(
                                  'سلام ${me.displayName}',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'همین عددها را همهٔ صندوق می‌بینند. از واریز شما چیزی کم نمی‌شود.',
                                  style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.6),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: MemberStatCard(
                                        title: 'سهم من',
                                        value: me.shareBalance,
                                        color: AppColors.navy,
                                        icon: Icons.savings_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: MemberStatCard(
                                        title: 'بدهی من',
                                        value: me.debt,
                                        color: AppColors.danger,
                                        icon: Icons.south_west,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: MemberStatCard(
                                        title: 'طلب من',
                                        value: me.credit,
                                        color: AppColors.gold,
                                        icon: Icons.north_east,
                                      ),
                                    ),
                                  ],
                                ),
                                const SectionHeader('اقساط پیش‌رو'),
                                if (upcoming.isEmpty)
                                  const EmptyView(
                                    title: 'قسط بازی ندارید',
                                    subtitle: 'وقتی وامی فعال شود، اقساط با سررسید اینجا می‌آید.',
                                    icon: Icons.event_available_outlined,
                                  )
                                else
                                  ...upcoming.map(
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: MemberInstallmentCard(item: i),
                                    ),
                                  ),
                                const SectionHeader('تاریخچه تراکنش‌ها'),
                                const SizedBox(height: 4),
                                TxHistoryFilterBar(
                                  selected: dashState.filter,
                                  onSelected: cubit.setFilter,
                                ),
                                const SizedBox(height: 12),
                                if (history.isEmpty)
                                  const EmptyView(
                                    title: 'تراکنشی در این فیلتر نیست',
                                    subtitle: 'پرداخت‌های ثبت‌شده پس از ارسال اینجا دیده می‌شوند.',
                                    icon: Icons.receipt_long_outlined,
                                  )
                                else
                                  ...history.map(
                                    (t) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: MemberTxTile(tx: t),
                                    ),
                                  ),
                                const SizedBox(height: 72),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: () => context.push('/pay'),
                          icon: const Icon(Icons.add_card_outlined),
                          label: const Text('ثبت پرداخت'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
