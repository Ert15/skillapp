import 'package:flutter_test/flutter_test.dart';
import 'package:skillswap/main.dart';

void main() {
  testWidgets('shows the welcome screen without Firebase', (tester) async {
    await tester.pumpWidget(const SkillSwapApp());

    expect(find.text('Меняйтесь навыками,\nа не деньгами'), findsOneWidget);
    expect(find.text('СОЗДАТЬ АККАУНТ'), findsOneWidget);
  });
}
