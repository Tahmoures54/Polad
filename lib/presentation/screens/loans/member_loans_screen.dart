import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../blocs/app_blocs.dart';
import '../home/member_widgets.dart';
import 'loan_widgets.dart';

/// لیست وام‌های عضو با وضعیت.
class MemberLoansScreen extends StatelessWidget {
  const MemberLoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('وام‌های من')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/loan-request'),
        label: const Text('درخواست وام'),
        icon: const Icon(Icons.add),
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final loans = [...state.myLoans]..sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
          return RefreshIndicator(
            color: AppColors.navy,
            onRefresh: () => context.read<HomeCubit>().refresh(),
            child: loans.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      EmptyView(
                        title: 'هنوز وامی ندارید',
                        subtitle: 'درخواست قرض‌الحسنه را بفرستید تا مدیر بررسی کند.',
                        icon: Icons.handshake_outlined,
                      ),
                    ],
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: loans
                        .map(
                          (l) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: LoanCard(
                              loan: l,
                              onTap: () => context.push('/loan-detail', extra: l.id),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          );
        },
      ),
    );
  }
}

/// جزئیات یک وام و اقساط همان پرونده.
class LoanDetailScreen extends StatelessWidget {
  const LoanDetailScreen({super.key, required this.loanId});

  final String loanId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final loan = state.loans.where((l) => l.id == loanId).firstOrNull;
        if (loan == null) {
          return const Scaffold(body: EmptyView(title: 'وام پیدا نشد'));
        }
        final inst = state.installments.where((i) => i.loanId == loanId).toList()
          ..sort((a, b) => a.sequence.compareTo(b.sequence));
        return Scaffold(
          appBar: AppBar(title: const Text('جزئیات وام')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              LoanCard(loan: loan),
              const SectionHeader('اقساط این وام'),
              if (inst.isEmpty)
                const EmptyView(
                  title: 'قسطی ساخته نشده',
                  subtitle: 'پس از تأیید مدیر، جدول اقساط با کارمزد ۲٪ اینجا می‌آید.',
                  icon: Icons.event_note_outlined,
                )
              else
                ...inst.map(
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MemberInstallmentCard(item: i),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
