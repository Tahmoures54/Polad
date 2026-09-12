import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../domain/enums.dart';
import '../../blocs/app_blocs.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.child, required this.index});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeCubit>().state;
    final admin = home.isAdmin;
    return BlocListener<HomeCubit, HomeState>(
      listenWhen: (p, c) => c.message != null && c.message != p.message,
      listener: (context, state) {
        final msg = state.message;
        if (msg == null) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        context.read<HomeCubit>().clearMessage();
      },
      child: Scaffold(
      body: Column(
        children: [
          OfflineBanner(visible: !context.watch<SessionCubit>().state.online),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (admin) {
            const paths = ['/home', '/pending', '/members', '/more'];
            context.go(paths[i]);
          } else {
            const paths = ['/home', '/installments', '/pay', '/more'];
            context.go(paths[i]);
          }
        },
        destinations: admin
            ? const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'),
                NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt), label: 'تأییدها'),
                NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups), label: 'اعضا'),
                NavigationDestination(icon: Icon(Icons.menu), selectedIcon: Icon(Icons.menu_open), label: 'بیشتر'),
              ]
            : const [
                NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'),
                NavigationDestination(icon: Icon(Icons.event_note_outlined), selectedIcon: Icon(Icons.event_note), label: 'اقساط'),
                NavigationDestination(icon: Icon(Icons.add_card_outlined), selectedIcon: Icon(Icons.add_card), label: 'پرداخت'),
                NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'من'),
              ],
      ),
    ),
    );
  }
}

class MemberDashboard extends StatelessWidget {
  const MemberDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.loading || state.me == null) return const LoadingView();
        final me = state.me!;
        final upcoming = state.myInstallments.where((i) => i.status != InstallmentStatus.paid).take(4).toList();
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Text(state.fund?.name ?? 'پولاد'),
              actions: [
                IconButton(onPressed: () => context.push('/pay'), icon: const Icon(Icons.add_card_outlined)),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(children: [
                Text('سلام ${me.displayName}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: SummaryCard(title: 'سهم من', value: me.shareBalance, icon: Icons.savings_outlined, color: AppColors.navy)),
                  const SizedBox(width: 10),
                  Expanded(child: SummaryCard(title: 'بدهی من', value: me.debt, icon: Icons.south_west, color: AppColors.danger)),
                ]),
                const SizedBox(height: 10),
                SummaryCard(title: 'طلب من', value: me.credit, icon: Icons.north_east, color: AppColors.success),
                const SectionHeader('اقساط پیش‌رو'),
                if (upcoming.isEmpty)
                  const EmptyView(title: 'قسط بازی ندارید', subtitle: 'وقتی وامی فعال شود، اقساط اینجا می‌آید.', icon: Icons.event_available_outlined)
                else
                  ...upcoming.map((i) => _InstallmentTile(item: i)),
                const SectionHeader('آخرین تراکنش‌ها'),
                ...state.transactions.where((t) => t.memberId == me.userId).take(6).map(_TxTile.new),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.push('/pay'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('ثبت پرداخت'),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.loading || state.fund == null) return const LoadingView();
        final fund = state.fund!;
        return CustomScrollView(
          slivers: [
            SliverAppBar(pinned: true, title: Text(fund.name)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList.list(children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(width: 160, child: SummaryCard(title: 'موجودی صندوق', value: fund.balance, icon: Icons.account_balance_wallet_outlined)),
                    SizedBox(width: 160, child: SummaryCard(title: 'اعضا', value: fund.memberCount, icon: Icons.groups_outlined, color: AppColors.gold)),
                    SizedBox(width: 160, child: SummaryCard(title: 'وام فعال', value: state.activeLoans, icon: Icons.handshake_outlined, color: AppColors.info)),
                    SizedBox(width: 160, child: SummaryCard(title: 'اقساط معوق', value: state.overdueCount, icon: Icons.warning_amber_outlined, color: AppColors.danger)),
                  ],
                ),
                SectionHeader('در انتظار تأیید', action: TextButton(onPressed: () => context.go('/pending'), child: Text('${faNum(state.pending.length)} مورد'))),
                if (state.pending.isEmpty)
                  const EmptyView(title: 'مورد معلقی نیست', subtitle: 'پرداخت‌های ثبت‌شده اعضا اینجا ظاهر می‌شود.', icon: Icons.verified_outlined)
                else
                  ...state.pending.take(3).map((t) => PendingTxCard(tx: t)),
                const SectionHeader('میان‌برها'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Quick('اعضا', Icons.person_add_alt, () => context.go('/members')),
                    _Quick('وام‌ها', Icons.handshake_outlined, () => context.push('/loans')),
                    _Quick('قرعه‌کشی', Icons.casino_outlined, () => context.push('/draws')),
                    _Quick('گزارش', Icons.insights_outlined, () => context.push('/reports')),
                  ],
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick(this.label, this.icon, this.onTap);
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.navy),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.divider),
    );
  }
}

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('در انتظار تأیید')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state.pending.isEmpty) {
            return const EmptyView(title: 'صف تأیید خالی است', icon: Icons.task_alt);
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.pending.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) => PendingTxCard(tx: state.pending[i], expanded: true),
          );
        },
      ),
    );
  }
}

class PendingTxCard extends StatelessWidget {
  const PendingTxCard({super.key, required this.tx, this.expanded = false});
  final dynamic tx;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final t = tx as dynamic;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(t.memberName as String, style: const TextStyle(fontWeight: FontWeight.w700))),
                StatusChip(label: (t.status as TransactionStatus).fa, tone: ChipTone.warning),
              ],
            ),
            const SizedBox(height: 8),
            AmountText(t.amount as int),
            const SizedBox(height: 6),
            Text('${(t.type as TransactionType).fa} • کد ${faNum(t.trackingCode ?? '—')}'),
            Text(jalaliDateTime(t.submittedAt as DateTime), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            if (expanded) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                      onPressed: () => context.read<HomeCubit>().approveTx(t.id as String),
                      child: const Text('تأیید'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                      onPressed: () async {
                        final ok = await confirmSheet(context, title: 'رد تراکنش', message: 'این پرداخت ثبت نمی‌شود و عضو باید دوباره ارسال کند.', confirmLabel: 'رد کردن', destructive: true);
                        if (ok && context.mounted) {
                          context.read<HomeCubit>().rejectTx(t.id as String, 'رد توسط مدیر');
                        }
                      },
                      child: const Text('رد'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اعضا'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () async {
              final cubit = context.read<HomeCubit>();
              final link = await cubit.inviteLink();
              final code = cubit.state.fund?.inviteCode ?? '';
              await SharePlus.instance.share(ShareParams(text: 'به صندوق پولاد بپیوندید\nکد دعوت: $code\n$link'));
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('لینک دعوت'),
                  subtitle: Text(state.fund?.inviteCode ?? '', style: const TextStyle(fontFamily: 'VazirmatnFD', fontSize: 20, fontWeight: FontWeight.w700)),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      final link = await context.read<HomeCubit>().inviteLink();
                      await Clipboard.setData(ClipboardData(text: '${state.fund?.inviteCode}\n$link'));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کد دعوت کپی شد')));
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...state.members.map((m) {
                return Card(
                  child: ListTile(
                    title: Text(m.displayName),
                    subtitle: Text('${m.role.fa} • سهم ${tomanCompact(m.shareBalance)} • بدهی ${tomanCompact(m.debt)}'),
                    trailing: state.isAdmin && m.userId != state.me?.userId
                        ? PopupMenuButton<String>(
                            onSelected: (v) async {
                              final cubit = context.read<HomeCubit>();
                              if (v == 'remove') {
                                final ok = await confirmSheet(context, title: 'حذف عضو', message: 'این فرد دیگر به صندوق دسترسی ندارد.', destructive: true, confirmLabel: 'حذف');
                                if (ok && context.mounted) cubit.removeMember(m.userId);
                                return;
                              }
                              if (v == 'admin') cubit.changeRole(m.userId, UserRole.admin);
                              if (v == 'member') cubit.changeRole(m.userId, UserRole.member);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'admin', child: Text('تبدیل به مدیر')),
                              PopupMenuItem(value: 'member', child: Text('تبدیل به عضو')),
                              PopupMenuItem(value: 'remove', child: Text('حذف')),
                            ],
                          )
                        : StatusChip(label: m.role.fa, tone: m.isAdmin ? ChipTone.info : ChipTone.neutral),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _InstallmentTile extends StatelessWidget {
  const _InstallmentTile({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final i = item;
    final tone = switch (i.status as InstallmentStatus) {
      InstallmentStatus.paid => ChipTone.success,
      InstallmentStatus.overdue => ChipTone.danger,
      InstallmentStatus.upcoming => ChipTone.warning,
    };
    return Card(
      child: ListTile(
        title: Text('قسط ${faNum(i.sequence)}'),
        subtitle: Text('سررسید ${jalaliDate(i.dueDate as DateTime)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(toman(i.amount as int), style: const TextStyle(fontFamily: 'VazirmatnFD', fontWeight: FontWeight.w700)),
            StatusChip(label: (i.status as InstallmentStatus).fa, tone: tone),
          ],
        ),
        onTap: i.status == InstallmentStatus.paid ? null : () => context.push('/pay', extra: i.id),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  const _TxTile(this.tx);
  final dynamic tx;

  @override
  Widget build(BuildContext context) {
    final tone = switch (tx.status as TransactionStatus) {
      TransactionStatus.approved => ChipTone.success,
      TransactionStatus.rejected => ChipTone.danger,
      TransactionStatus.pending => ChipTone.warning,
    };
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text((tx.type as TransactionType).fa),
      subtitle: Text(jalaliDate(tx.occurredAt as DateTime)),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(toman(tx.amount as int), style: const TextStyle(fontFamily: 'VazirmatnFD')),
          StatusChip(label: (tx.status as TransactionStatus).fa, tone: tone),
        ],
      ),
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<HomeCubit>().state.isAdmin;
    return Scaffold(
      appBar: AppBar(title: const Text('بیشتر')),
      body: ListView(
        children: [
          if (admin) ...[
            ListTile(leading: const Icon(Icons.handshake_outlined), title: const Text('وام و اقساط'), onTap: () => context.push('/loans')),
            ListTile(leading: const Icon(Icons.casino_outlined), title: const Text('قرعه‌کشی'), onTap: () => context.push('/draws')),
            ListTile(leading: const Icon(Icons.insights_outlined), title: const Text('گزارش‌ها'), onTap: () => context.push('/reports')),
            ListTile(leading: const Icon(Icons.receipt_long_outlined), title: const Text('صورتحساب خدمات نرم‌افزاری'), onTap: () => context.push('/billing')),
            ListTile(leading: const Icon(Icons.tune), title: const Text('تنظیمات صندوق'), onTap: () => context.push('/fund-settings')),
            ListTile(leading: const Icon(Icons.sms_outlined), title: const Text('تطبیق پیامک بانکی'), onTap: () => context.push('/sms')),
          ],
          ListTile(leading: const Icon(Icons.person_outline), title: const Text('پروفایل'), onTap: () => context.push('/profile')),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text('خروج از حساب', style: TextStyle(color: AppColors.danger)),
            onTap: () async {
              final ok = await confirmSheet(context, title: 'خروج', message: 'از حساب خارج می‌شوید.', confirmLabel: 'خروج', destructive: true);
              if (ok && context.mounted) {
                await context.read<SessionCubit>().signOut();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

class InstallmentsScreen extends StatelessWidget {
  const InstallmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اقساط من')),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final items = state.myInstallments;
          if (items.isEmpty) return const EmptyView(title: 'قسطی ثبت نشده');
          return ListView(padding: const EdgeInsets.all(16), children: items.map((i) => _InstallmentTile(item: i)).toList());
        },
      ),
    );
  }
}
