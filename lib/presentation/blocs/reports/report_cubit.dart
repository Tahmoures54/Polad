import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import '../../../core/di/locator.dart';
import '../../../domain/entities/reports.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';

/// Cubit گزارش مدیر: فیلتر بازه / عضو / نوع + خروجی فایل.
class ReportCubit extends Cubit<ReportUiState> {
  ReportCubit({required this.fundId, ReportRepository? repo})
      : _repo = repo ?? sl<ReportRepository>(),
        super(const ReportUiState());

  final String fundId;
  final ReportRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final report = await _repo.build(fundId, filter: state.filter);
      emit(state.copyWith(busy: false, report: report));
    } catch (e) {
      emit(state.copyWith(busy: false, error: 'گزارش ساخته نشد. دوباره تلاش کنید.'));
    }
  }

  Future<void> apply(ReportFilter filter) async {
    emit(state.copyWith(filter: filter));
    await load();
  }

  Future<void> setMember(String? memberId) =>
      apply(state.filter.copyWith(memberId: memberId, clearMember: memberId == null));

  Future<void> setType(TransactionType? type) =>
      apply(state.filter.copyWith(type: type, clearType: type == null));

  Future<void> setJalaliRange(Jalali? from, Jalali? to) {
    return apply(
      state.filter.copyWith(
        from: from?.toDateTime(),
        to: to?.toDateTime(),
        clearDates: from == null && to == null,
      ),
    );
  }

  Future<void> exportExcel() async {
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _repo.exportExcel(fundId, filter: state.filter);
    res.when(
      ok: (_) => emit(state.copyWith(busy: false, message: 'فایل اکسل آماده شد')),
      err: (m) => emit(state.copyWith(busy: false, error: m)),
    );
  }

  Future<void> exportPdf() async {
    emit(state.copyWith(busy: true, clearError: true));
    final res = await _repo.exportPdf(fundId, filter: state.filter);
    res.when(
      ok: (_) => emit(state.copyWith(busy: false, message: 'فایل PDF آماده شد')),
      err: (m) => emit(state.copyWith(busy: false, error: m)),
    );
  }
}

class ReportUiState extends Equatable {
  const ReportUiState({
    this.busy = false,
    this.report,
    this.filter = const ReportFilter(),
    this.error,
    this.message,
  });

  final bool busy;
  final PoladReport? report;
  final ReportFilter filter;
  final String? error;
  final String? message;

  ReportUiState copyWith({
    bool? busy,
    PoladReport? report,
    ReportFilter? filter,
    String? error,
    String? message,
    bool clearError = false,
  }) {
    return ReportUiState(
      busy: busy ?? this.busy,
      report: report ?? this.report,
      filter: filter ?? this.filter,
      error: clearError ? null : (error ?? this.error),
      message: clearError ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [busy, report, filter, error, message];
}
