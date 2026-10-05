import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_practice/main.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Grammar is the initial view and can be checked with Enter', (
    tester,
  ) async {
    await tester.pumpWidget(const PracticeApp());
    await tester.pumpAndSettle();
    expect(find.text('Completa la frase'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField),
      'a deliberately wrong answer',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Incorrecto'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Comprobar'), findsOneWidget);
  });

  testWidgets('Reading preserves answers when returning to its text', (
    tester,
  ) async {
    await tester.pumpWidget(const PracticeApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hacer Reading'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Siguiente'));
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'My own interpretation',
    );
    await tester.ensureVisible(find.text('Volver'));
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Siguiente'));
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('My own interpretation'), findsOneWidget);
    await tester.ensureVisible(find.text('Comprobar'));
    await tester.tap(find.text('Comprobar'));
    await tester.pumpAndSettle();
    expect(find.text('Correcto'), findsNothing);
    expect(find.text('Incorrecto'), findsNothing);
  });

  testWidgets(
    'Writing opens its topic popup and preserves the draft across sections',
    (tester) async {
      await tester.pumpWidget(const PracticeApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Writing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cargar Writing'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Escribir'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'A draft with español.');
      await tester.tap(find.text('Grammar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Writing'));
      await tester.pumpAndSettle();
      expect(find.text('A draft with español.'), findsOneWidget);
    },
  );

  testWidgets(
    'Vocabulary records recall and provides both language directions',
    (tester) async {
      await tester.pumpWidget(const PracticeApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vocabulary'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'incorrect answer');
      await tester.tap(find.text('Comprobar'));
      await tester.pumpAndSettle();
      expect(find.text('Incorrecto'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('vocabulary-progress'), contains('en-es:'));
      await tester.tap(find.text('English → Español'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Español → English').last);
      await tester.pumpAndSettle();
      expect(find.text('Significado en inglés'), findsOneWidget);
    },
  );
}
