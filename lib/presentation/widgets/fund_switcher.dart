import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/locator.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/people.dart';
import '../../domain/repositories/repositories.dart';
import '../blocs/app_blocs.dart';

/// تعویض صندوق فعال برای کاربری که در چند صندوق عضو است.
class FundSwitcherButton extends StatelessWidget {
  const FundSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'تغییر صندوق',
      icon: const Icon(Icons.swap_horiz),
      onPressed: () => showFundSwitcher(context),
    );
  }
}

class FundSwitcherStrip extends StatelessWidget {
  const FundSwitcherStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.watch<HomeCubit>().state.fund?.name ?? '';
    return InkWell(
      onTap: () => showFundSwitcher(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.navy.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance, color: AppColors.navy, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))),
            const Text('تغییر صندوق', style: TextStyle(color: AppColors.navy, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

Future<void> showFundSwitcher(BuildContext context) async {
  final funds = await sl<FundRepository>().myFunds();
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final active = ctx.read<HomeCubit>().fundId;
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('صندوق فعال')),
            ...funds.map(
              (Fund f) => ListTile(
                title: Text(f.name),
                selected: f.id == active,
                trailing: f.id == active ? const Icon(Icons.check, color: AppColors.navy) : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  await sl<FundRepository>().setActiveFund(f.id);
                  if (context.mounted) context.go('/boot');
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('ایجاد صندوق جدید'),
              onTap: () {
                Navigator.pop(ctx);
                ctx.push('/setup');
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('پیوستن با کد دعوت'),
              onTap: () {
                Navigator.pop(ctx);
                ctx.push('/join');
              },
            ),
          ],
        ),
      );
    },
  );
}
