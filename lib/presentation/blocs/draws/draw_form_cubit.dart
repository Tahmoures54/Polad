import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/enums.dart';
import '../../../domain/repositories/repositories.dart';

class DrawFormState extends Equatable {
  const DrawFormState({
    this.title = 'قرعه‌کشی سهم',
    this.prizeText = '',
    this.start,
    this.end,
    this.mode = DrawSelectionMode.random,
    this.submitted = false,
    this.busy = false,
    this.error,
    this.success = false,
  });

  final String title;
  final String prizeText;
  final DateTime? start;
  final DateTime? end;
  final DrawSelectionMode mode;
  final bool submitted;
  final bool busy;
  final String? error;
  final bool success;

  DateTime get startDate => start ?? DateTime.now();
  DateTime get endDate => end ?? DateTime.now().add(const Duration(days: 30));

  String? get titleError {
    if (!submitted && title.trim().isEmpty) return null;
    return Validators.requiredText(title, label: 'عنوان دوره');
  }

  String? get prizeError {
    if (!submitted && prizeText.isEmpty) return null;
    return Validators.amount(prizeText);
  }

  DrawFormState copyWith({
    String? title,
    String? prizeText,
    DateTime? start,
    DateTime? end,
    DrawSelectionMode? mode,
    bool? submitted,
    bool? busy,
    String? error,
    bool? success,
    bool clearError = false,
  }) {
    return DrawFormState(
      title: title ?? this.title,
      prizeText: prizeText ?? this.prizeText,
      start: start ?? this.start,
      end: end ?? this.end,
      mode: mode ?? this.mode,
      submitted: submitted ?? this.submitted,
      busy: busy ?? this.busy,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [title, prizeText, start, end, mode, submitted, busy, error, success];
}

/// ایجاد دوره قرعه‌کشی توسط مدیر.
class DrawFormCubit extends Cubit<DrawFormState> {
  DrawFormCubit({DrawRepository? draws})
      : _draws = draws ?? sl<DrawRepository>(),
        super(DrawFormState(start: DateTime.now(), end: DateTime.now().add(const Duration(days: 30))));

  final DrawRepository _draws;

  void titleChanged(String value) => emit(state.copyWith(title: value, success: false, clearError: true));

  void prizeChanged(String value) => emit(state.copyWith(prizeText: value, success: false, clearError: true));

  void startChanged(DateTime value) => emit(state.copyWith(start: value));

  void endChanged(DateTime value) => emit(state.copyWith(end: value));

  void modeChanged(DrawSelectionMode mode) => emit(state.copyWith(mode: mode));

  Future<void> submit() async {
    emit(state.copyWith(submitted: true, clearError: true));
    if (state.titleError != null || state.prizeError != null) return;
    final prize = Validators.parseAmount(state.prizeText);
    if (prize == null) return;
    if (state.endDate.isBefore(state.startDate)) {
      emit(state.copyWith(error: 'پایان دوره باید بعد از شروع باشد'));
      return;
    }
    emit(state.copyWith(busy: true));
    final res = await _draws.create(
      title: state.title.trim(),
      start: state.startDate,
      end: state.endDate,
      prizeAmount: prize,
      mode: state.mode,
    );
    res.when(
      ok: (_) => emit(state.copyWith(busy: false, success: true)),
      err: (m) => emit(state.copyWith(busy: false, error: m)),
    );
  }
}
