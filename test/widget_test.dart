import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polad/core/theme/app_colors.dart';
import 'package:polad/core/theme/app_theme.dart';
import 'package:polad/core/utils/formatters.dart';
import 'package:polad/core/widgets/app_widgets.dart';

void main() {
  test('toman formats with persian digits', () {
    expect(toman(5000000), contains('تومان'));
    expect(toman(5000000), isNot(contains('5')));
  });

  testWidgets('status chip and empty state render in RTL', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Column(
              children: [
                StatusChip(label: 'در انتظار تأیید', tone: ChipTone.warning),
                EmptyView(title: 'صف تأیید خالی است'),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('در انتظار تأیید'), findsOneWidget);
    expect(find.text('صف تأیید خالی است'), findsOneWidget);
  });

  test('brand colors match indigo and gold', () {
    expect(AppColors.navy, const Color(0xFF1A237E));
    expect(AppColors.gold, const Color(0xFFFFD700));
  });
}
