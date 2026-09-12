import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/locator.dart';
import '../../../domain/entities/finance.dart';
import '../../../domain/entities/people.dart';
import '../../../domain/repositories/repositories.dart';

class DrawRunState extends Equatable {
  const DrawRunState({
    this.spinningName,
    this.running = false,
    this.winner,
    this.error,
  });

  final String? spinningName;
  final bool running;
  final FundDraw? winner;
  final String? error;

  DrawRunState copyWith({
    String? spinningName,
    bool? running,
    FundDraw? winner,
    String? error,
    bool clearError = false,
    bool clearWinner = false,
  }) {
    return DrawRunState(
      spinningName: spinningName ?? this.spinningName,
      running: running ?? this.running,
      winner: clearWinner ? null : (winner ?? this.winner),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [spinningName, running, winner, error];
}

/// انیمیشن سادهٔ چرخش نام‌ها و ثبت برنده (تصادفی یا دستی).
class DrawRunCubit extends Cubit<DrawRunState> {
  DrawRunCubit({required this.drawId, DrawRepository? draws})
      : _draws = draws ?? sl<DrawRepository>(),
        super(const DrawRunState());

  final String drawId;
  final DrawRepository _draws;
  Timer? _timer;
  final _random = Random();

  Future<void> spinRandom(List<FundMember> members) async {
    if (state.running || members.isEmpty) {
      if (members.isEmpty) emit(state.copyWith(error: 'عضوی برای قرعه نیست'));
      return;
    }
    emit(state.copyWith(running: true, clearError: true, clearWinner: true));
    var i = _random.nextInt(members.length);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      i = (i + 1) % members.length;
      emit(state.copyWith(spinningName: members[i].displayName));
    });
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    _timer?.cancel();
    final res = await _draws.run(drawId: drawId);
    res.when(
      ok: (d) => emit(state.copyWith(running: false, winner: d, spinningName: d.winnerName)),
      err: (m) => emit(state.copyWith(running: false, error: m)),
    );
  }

  Future<void> pickManual(String memberId) async {
    if (state.running) return;
    emit(state.copyWith(running: true, clearError: true, clearWinner: true));
    final res = await _draws.run(drawId: drawId, manualWinnerId: memberId);
    res.when(
      ok: (d) => emit(state.copyWith(running: false, winner: d, spinningName: d.winnerName)),
      err: (m) => emit(state.copyWith(running: false, error: m)),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
