import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/services/finance_services.dart';
import '../app_blocs.dart';

class BillingUiState extends Equatable {
  const BillingUiState({this.year, this.month});

  final int? year;
  final int? month;

  DateTime get cursor {
    final now = DateTime.now();
    return DateTime(year ?? now.year, month ?? now.month);
  }

  @override
  List<Object?> get props => [year, month];
}

/// صورتحساب ماهانه کارمزد نرم‌افزار برای مدیر.
class BillingCubit extends Cubit<BillingUiState> {
  BillingCubit() : super(const BillingUiState());

  final revenue = const RevenueService();

  void setMonth(DateTime value) => emit(BillingUiState(year: value.year, month: value.month));

  MonthlyFeeSnapshot snapshot(HomeState home) => revenue.forMonth(
        fund: home.fund,
        transactions: home.transactions,
        invoices: home.invoices,
        now: state.cursor,
      );
}
