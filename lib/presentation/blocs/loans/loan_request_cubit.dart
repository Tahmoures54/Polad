import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/locator.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/people.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';
import '../../../domain/services/finance_services.dart';
import '../app_blocs.dart';

class LoanRequestState extends Equatable {
  const LoanRequestState({
    this.amountText = '',
    this.reason = '',
    this.months = 6,
    this.submitted = false,
    this.busy = false,
    this.error,
    this.success = false,
  });

  final String amountText;
  final String reason;
  final int months;
  final bool submitted;
  final bool busy;
  final String? error;
  final bool success;

  String? get amountError {
    if (!submitted && amountText.isEmpty) return null;
    return Validators.amount(amountText);
  }

  String? get reasonError {
    if (!submitted && reason.trim().isEmpty) return null;
    return Validators.requiredText(reason, label: 'دلیل درخواست');
  }

  LoanRequestState copyWith({
    String? amountText,
    String? reason,
    int? months,
    bool? submitted,
    bool? busy,
    String? error,
    bool? success,
    bool clearError = false,
  }) {
    return LoanRequestState(
      amountText: amountText ?? this.amountText,
      reason: reason ?? this.reason,
      months: months ?? this.months,
      submitted: submitted ?? this.submitted,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [amountText, reason, months, submitted, busy, error, success];
}

/// درخواست وام قرض‌الحسنه؛ پیش‌نمایش اقساط با کارمزد اداری ۲٪ (نه ربا).
class LoanRequestCubit extends Cubit<LoanRequestState> {
  LoanRequestCubit({
    LoanRepository? loans,
    InstallmentCalculator? calculator,
    LoanEligibility? eligibility,
  })  : _loans = loans ?? sl<LoanRepository>(),
        _calc = calculator ?? const InstallmentCalculator(),
        _elig = eligibility ?? const LoanEligibility(),
        super(const LoanRequestState());

  final LoanRepository _loans;
  final InstallmentCalculator _calc;
  final LoanEligibility _elig;

  void amountChanged(String value) => emit(state.copyWith(amountText: value, success: false, clearError: true));

  void reasonChanged(String value) => emit(state.copyWith(reason: value, success: false, clearError: true));

  void monthsChanged(int value) => emit(state.copyWith(months: value.clamp(3, 24), success: false));

  /// جدول اقساط با نرخ اداری صندوق (پیش‌فرض ۲٪).
  InstallmentPlan? previewOf(Fund? fund) {
    final amount = Validators.parseAmount(state.amountText);
    if (amount == null || fund == null) return null;
    try {
      return _calc.plan(
        principal: amount,
        termMonths: state.months,
        start: DateTime.now(),
        feeRate: fund.loanAdminFeeRate,
        periodDays: fund.paymentPeriodDays,
      );
    } catch (_) {
      return null;
    }
  }

  /// قواعد شفاف واجد شرایط بودن؛ نتیجه برای راهنمای فارسی روی فرم.
  String? denyReasonOf(HomeState home) {
    final amount = Validators.parseAmount(state.amountText);
    final fund = home.fund;
    final me = home.me;
    if (amount == null || fund == null || me == null) return null;
    final overdue = home.myInstallments.where((i) => i.status == InstallmentStatus.overdue).length;
    return _elig.denyReason(
      requested: amount,
      shareAmount: fund.shareAmount,
      memberShareBalance: me.shareBalance,
      overdueCount: overdue,
      fundBalance: fund.balance,
      isActiveMember: me.status == MemberStatus.active,
    );
  }

  Future<void> submit(HomeState home) async {
    emit(state.copyWith(submitted: true, clearError: true));
    if (state.amountError != null || state.reasonError != null) return;
    final deny = denyReasonOf(home);
    if (deny != null) {
      emit(state.copyWith(error: deny));
      return;
    }
    final amount = Validators.parseAmount(state.amountText);
    if (amount == null) return;
    emit(state.copyWith(busy: true));
    final res = await _loans.requestLoan(
      amount: amount,
      termMonths: state.months,
      reason: state.reason.trim(),
    );
    res.when(
      ok: (_) => emit(state.copyWith(busy: false, success: true)),
      err: (m) => emit(state.copyWith(busy: false, error: m)),
    );
  }

  /// نرخ نمایشی کارمزد اداری (معمولاً ۲٪).
  String feeLabel(Fund? fund) {
    final rate = fund?.loanAdminFeeRate ?? AppConstants.loanAdminFeeRate;
    return percentFa(rate);
  }
}
