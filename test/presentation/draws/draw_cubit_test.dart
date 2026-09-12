import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polad/core/theme/app_theme.dart';
import 'package:polad/core/utils/result.dart';
import 'package:polad/domain/entities/finance.dart';
import 'package:polad/domain/enums.dart';
import 'package:polad/domain/repositories/repositories.dart';
import 'package:polad/presentation/blocs/draws/draw_form_cubit.dart';
import 'package:polad/presentation/blocs/draws/draw_run_cubit.dart';
import 'package:polad/presentation/screens/draws/draw_widgets.dart';

class FakeDrawRepo implements DrawRepository {
  Result<FundDraw> createResult = const Err('not set');
  Result<FundDraw> runResult = const Err('not set');
  CreateDrawCall? created;
  String? lastManual;

  @override
  Future<Result<FundDraw>> create({
    required String title,
    required DateTime start,
    required DateTime end,
    required int prizeAmount,
    required DrawSelectionMode mode,
  }) async {
    created = CreateDrawCall(title, prizeAmount, mode);
    return createResult;
  }

  @override
  Future<Result<FundDraw>> run({required String drawId, String? manualWinnerId}) async {
    lastManual = manualWinnerId;
    return runResult;
  }

  @override
  Stream<List<FundDraw>> watch(String fundId) => const Stream.empty();
}

class CreateDrawCall {
  CreateDrawCall(this.title, this.prize, this.mode);
  final String title;
  final int prize;
  final DrawSelectionMode mode;
}

FundDraw _draw({DrawStatus status = DrawStatus.ready, String? winner}) => FundDraw(
      id: 'd1',
      fundId: 'f1',
      title: 'قرعه بهار',
      periodStart: DateTime(2026, 3, 1),
      periodEnd: DateTime(2026, 4, 1),
      status: status,
      mode: DrawSelectionMode.random,
      prizeAmount: 10000000,
      winnerName: winner,
      eligibleMemberIds: const ['u1', 'u2'],
    );

void main() {
  test('draw form rejects empty prize', () async {
    final cubit = DrawFormCubit(draws: FakeDrawRepo());
    cubit.titleChanged('قرعه تابستان');
    await cubit.submit();
    expect(cubit.state.prizeError, isNotNull);
    expect(cubit.state.success, isFalse);
    await cubit.close();
  });

  test('draw form submits prize and mode', () async {
    final repo = FakeDrawRepo()
      ..createResult = Ok(_draw());
    final cubit = DrawFormCubit(draws: repo);
    cubit.titleChanged('قرعه تابستان');
    cubit.prizeChanged('۱۰٬۰۰۰٬۰۰۰');
    cubit.modeChanged(DrawSelectionMode.manual);
    await cubit.submit();
    expect(repo.created!.prize, 10000000);
    expect(repo.created!.mode, DrawSelectionMode.manual);
    expect(cubit.state.success, isTrue);
    await cubit.close();
  });

  test('manual pick records winner without auto-approve side effects', () async {
    final repo = FakeDrawRepo()
      ..runResult = Ok(_draw(status: DrawStatus.completed, winner: 'علی'));
    final cubit = DrawRunCubit(drawId: 'd1', draws: repo);
    await cubit.pickManual('u2');
    expect(repo.lastManual, 'u2');
    expect(cubit.state.winner!.winnerName, 'علی');
    expect(cubit.state.running, isFalse);
    await cubit.close();
  });

  testWidgets('draw card shows history winner in persian', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: DrawCard(draw: _draw(status: DrawStatus.completed, winner: 'مریم')),
        ),
      ),
    );
    expect(find.text('انجام‌شده'), findsOneWidget);
    expect(find.text('برنده: مریم'), findsOneWidget);
    expect(find.textContaining('جایزه'), findsOneWidget);
  });
}
