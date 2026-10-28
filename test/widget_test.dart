import 'package:flutter_test/flutter_test.dart';
import 'package:taskmate/main.dart';

void main() {
  testWidgets('TaskMate app tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskMateApp());

    expect(find.text('TaskMate'), findsWidgets);
    expect(find.text('Beranda'), findsOneWidget);
  });
}
