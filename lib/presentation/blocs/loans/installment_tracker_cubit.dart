import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

import '../../../domain/entities/finance.dart';
import '../../../domain/enums.dart';
import '../app_blocs.dart';

/// فیلتر پیگیری اقساط برای مدیر.
enum AdminInstFilter {
  all,
  upcoming,
  overdue,
  paid,
}

extension AdminInstFilterX on AdminInstFilter {
  String get label => switch (this) {
        AdminInstFilter.all => 'همه',
        AdminInstFilter.upcoming => 'در انتظار',
        AdminInstFilter.overdue => 'معوق',
        AdminInstFilter.paid => 'پرداخت‌شده',
      };
}

class InstallmentTrackerState extends Equatable {
  const InstallmentTrackerState({this.filter = AdminInstFilter.all});

  final AdminInstFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// فیلتر و مرتب‌سازی اقساط همهٔ اعضا برای صفحهٔ پیگیری مدیر.
class InstallmentTrackerCubit extends Cubit<InstallmentTrackerState> {
  InstallmentTrackerCubit() : super(const InstallmentTrackerState());

  void setFilter(AdminInstFilter filter) => emit(InstallmentTrackerState(filter: filter));

  List<Installment> filtered(HomeState home) {
    final items = [...home.installments];
    final out = switch (state.filter) {
      AdminInstFilter.all => items,
      AdminInstFilter.upcoming => items.where((i) => i.status == InstallmentStatus.upcoming).toList(),
      AdminInstFilter.overdue => items.where((i) => i.status == InstallmentStatus.overdue).toList(),
      AdminInstFilter.paid => items.where((i) => i.status == InstallmentStatus.paid).toList(),
    }..sort((a, b) {
        final rank = _rank(a.status).compareTo(_rank(b.status));
        if (rank != 0) return rank;
        return a.dueDate.compareTo(b.dueDate);
      });
    return out;
  }

  int _rank(InstallmentStatus status) => switch (status) {
        InstallmentStatus.overdue => 0,
        InstallmentStatus.upcoming => 1,
        InstallmentStatus.paid => 2,
      };

  String memberName(HomeState home, String memberId) {
    return home.members.where((m) => m.userId == memberId).map((m) => m.displayName).firstOrNull ?? 'عضو';
  }
}
