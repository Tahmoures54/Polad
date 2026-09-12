import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/finance.dart';
import '../../../domain/enums.dart';
import '../app_blocs.dart';

/// فیلتر تاریخچهٔ پرداخت‌های عضو.
enum TxHistoryFilter {
  /// همهٔ تراکنش‌های عضو.
  all,

  /// فقط تأییدشده توسط مدیر.
  approved,

  /// منتظر تأیید (`pending_approval`).
  pending,
}

extension TxHistoryFilterX on TxHistoryFilter {
  String get label => switch (this) {
        TxHistoryFilter.all => 'همه',
        TxHistoryFilter.approved => 'تأییدشده',
        TxHistoryFilter.pending => 'در انتظار',
      };
}

class MemberDashboardState extends Equatable {
  const MemberDashboardState({this.filter = TxHistoryFilter.all});

  final TxHistoryFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// وضعیت نمایش داشبورد عضو: فیلتر تاریخچه روی داده‌های [HomeCubit].
class MemberDashboardCubit extends Cubit<MemberDashboardState> {
  MemberDashboardCubit() : super(const MemberDashboardState());

  void setFilter(TxHistoryFilter filter) => emit(MemberDashboardState(filter: filter));

  /// اقساط عضو؛ معوق‌ها اول، بعد پیش‌رو، بعد پرداخت‌شده.
  List<Installment> upcomingOf(HomeState home) {
    final items = [...home.myInstallments]
      ..sort((a, b) {
        final rank = _statusRank(a.status).compareTo(_statusRank(b.status));
        if (rank != 0) return rank;
        return a.dueDate.compareTo(b.dueDate);
      });
    return items;
  }

  int _statusRank(InstallmentStatus status) => switch (status) {
        InstallmentStatus.overdue => 0,
        InstallmentStatus.upcoming => 1,
        InstallmentStatus.paid => 2,
      };

  /// تاریخچه با فیلتر انتخاب‌شده (جدیدتر بالا).
  List<MoneyTransaction> historyOf(HomeState home) {
    final filtered = switch (state.filter) {
      TxHistoryFilter.all => home.myTransactions,
      TxHistoryFilter.approved =>
        home.myTransactions.where((t) => t.status == TransactionStatus.approved).toList(),
      TxHistoryFilter.pending =>
        home.myTransactions.where((t) => t.status == TransactionStatus.pending).toList(),
    };
    final out = [...filtered]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return out;
  }
}
