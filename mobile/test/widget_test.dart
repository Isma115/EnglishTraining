import 'dart:convert';

// file_picker 11 exposes its platform test hook only through this library.
// ignore: implementation_imports
import 'package:file_picker/src/platform/file_picker_method_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_practice/main.dart';

Future<void> startApp(WidgetTester tester) async {
  // Asset strings are decoded in an isolate, which needs real asynchronous time.
  await tester.runAsync(() async {
    await tester.pumpWidget(const PracticeApp());
    for (final name in [
      'grammar',
      'reading',
      'writing',
      'vocabulary',
      'translation',
    ]) {
      await rootBundle.loadString('assets/data/$name.json');
    }
    await SharedPreferences.getInstance();
    await Future<void>.delayed(Duration.zero);
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'Writing compares both texts side by side and preserves highlights and edits',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await startApp(tester);
      await tester.tap(find.text('Writing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cargar Writing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Escribir'));
      await tester.pumpAndSettle();
      const original = 'I has a dog.\nA friendly pet.';
      const corrected = 'I have a dog.\nA friendly pet.';
      await tester.enterText(find.byType(TextField).first, original);
      await tester.enterText(find.byType(TextField).last, corrected);
      await tester.ensureVisible(find.text('Comparar'));
      await tester.tap(find.text('Comparar'));
      await tester.pumpAndSettle();
      final texts = tester
          .widgetList<SelectableText>(find.byType(SelectableText))
          .toList();
      expect(texts.length, 2);
      expect(texts[0].textSpan!.toPlainText(), original);
      expect(texts[1].textSpan!.toPlainText(), corrected);
      final removed = texts[0].textSpan!.children!
          .whereType<TextSpan>()
          .firstWhere((part) => part.text == 'has');
      final added = texts[1].textSpan!.children!
          .whereType<TextSpan>()
          .firstWhere((part) => part.text == 'have');
      expect(removed.style!.decoration, TextDecoration.lineThrough);
      expect(added.style!.decoration, TextDecoration.underline);
      expect(
        tester.getTopLeft(find.byType(SelectableText).first).dy,
        tester.getTopLeft(find.byType(SelectableText).last).dy,
      );
      await tester.tap(find.text('Grammar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Writing'));
      await tester.pumpAndSettle();
      expect(find.text('Editar textos'), findsOneWidget);
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Editar textos'));
      await tester.tap(find.text('Editar textos'));
      await tester.pumpAndSettle();
      final fields = tester
          .widgetList<TextField>(find.byType(TextField))
          .toList();
      expect(fields.first.controller!.text, original);
      expect(fields.last.controller!.text, corrected);
    },
  );

  testWidgets(
    'Writing exports exact UTF-8 and handles empty, cancelled and failed saves',
    (tester) async {
      const channel = MethodChannel('miguelruivo.flutter.plugins.filepicker');
      final calls = <MethodCall>[];
      String? result = '/mock/writing.txt';
      var fail = false;
      MethodChannelFilePicker.registerWith();
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (fail) throw PlatformException(code: 'write-failed');
        return result;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      await startApp(tester);
      await tester.tap(find.text('Writing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cargar Writing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Escribir'));
      await tester.pumpAndSettle();
      Future<void> save() async {
        await tester.ensureVisible(find.text('Guardar'));
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();
      }

      await save();
      expect(calls, isEmpty);
      expect(find.text('Escribe un writing antes de guardar.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      const draft = '  Español: café, niño.\nSecond paragraph.\n';
      await tester.enterText(find.byType(TextField).first, draft);
      await save();
      expect(calls.single.method, 'save');
      final args = calls.single.arguments as Map;
      expect(args['fileName'], 'writing.txt');
      expect(args['allowedExtensions'], ['txt']);
      expect(utf8.decode(args['bytes'] as List<int>), draft);
      expect(find.text('Guardado'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      result = null;
      await save();
      expect(calls.length, 2);
      expect(find.text('Guardado'), findsNothing);
      expect(find.text(draft), findsOneWidget);
      fail = true;
      await save();
      expect(find.text('No se pudo guardar el archivo.'), findsOneWidget);
      expect(find.text(draft), findsOneWidget);
    },
  );

  testWidgets('The five exercise sections fit a phone screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await startApp(tester);
    for (final name in [
      'Reading',
      'Writing',
      'Vocabulary',
      'Traducción',
      'Grammar',
    ]) {
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: name);
    }
    expect(find.text('Completa la frase'), findsOneWidget);
  });

  testWidgets('Invalid progress warns and recovers without blocking practice', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'vocabulary-progress': '[]'});
    await startApp(tester);
    await tester.tap(find.text('Vocabulary'));
    await tester.pumpAndSettle();
    expect(find.text('No se pudo recuperar el progreso.'), findsOneWidget);
    expect(find.text('Dificultad'), findsOneWidget);
    expect(find.text('Dirección'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'wrong');
    await tester.tap(find.text('Comprobar'));
    await tester.pumpAndSettle();
    expect(find.text('Incorrecto'), findsOneWidget);
    expect(find.text('No se pudo recuperar el progreso.'), findsNothing);
  });

  testWidgets(
    'Completed vocabulary accepts numeric timestamps and can switch difficulty',
    (tester) async {
      final bank = jsonDecode(
        (await tester.runAsync(
          () => rootBundle.loadString('assets/data/vocabulary.json'),
        ))!,
      ) as Map;
      final progress = {
        for (final item in bank['items'] as List)
          'en-es:${item['id']}': {
            'due': 4102444800000.5,
            'ease': 2.5,
            'interval': 1,
            'repetitions': 1.0,
          },
      };
      SharedPreferences.setMockInitialValues({
        'vocabulary-progress': jsonEncode(progress),
      });
      await startApp(tester);
      await tester.tap(find.text('Vocabulary'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Próximo repaso:'), findsOneWidget);
      expect(find.text('Actualizar'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Frecuente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Menos frecuente').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('Próximo repaso:'), findsOneWidget);
      await tester.tap(find.text('English → Español'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Español → English').last);
      await tester.pumpAndSettle();
      expect(find.text('Significado en inglés'), findsOneWidget);
      expect(find.textContaining('Próximo repaso:'), findsNothing);
    },
  );

  testWidgets(
    'Mixed translation keeps its order and drafts across navigation',
    (tester) async {
      Future<void> tap(String text) async {
        final target = find.text(text).last;
        await tester.ensureVisible(target);
        await tester.tap(target);
        await tester.pumpAndSettle();
      }

      String prompt() => tester
          .widget<SelectableText>(find.byType(SelectableText).first)
          .data!;

      await startApp(tester);
      await tap('Traducción');
      final orderedFirst = prompt();
      await tester.enterText(find.byType(TextField), 'My ordered draft.');
      await tap('Todos los bloques');
      await tap('Modo mezclado');
      expect(find.textContaining('Frase 1 de 800'), findsOneWidget);
      final mixedFirst = prompt();
      await tester.enterText(find.byType(TextField), 'My mixed draft.');
      await tap('Mostrar traducción');
      expect(prompt(), mixedFirst);
      await tap('Siguiente');
      expect(find.textContaining('Frase 2 de 800'), findsOneWidget);
      expect(prompt(), isNot(mixedFirst));
      expect(find.text('Traducción de referencia'), findsNothing);
      await tap('Anterior');
      expect(prompt(), mixedFirst);
      expect(find.text('My mixed draft.'), findsOneWidget);
      await tap('Grammar');
      await tap('Traducción');
      expect(prompt(), mixedFirst);
      expect(find.text('My mixed draft.'), findsOneWidget);
      await tap('Mostrar traducción');
      await tap('Volver a mezclar');
      expect(find.textContaining('Frase 1 de 800'), findsOneWidget);
      expect(find.text('Traducción de referencia'), findsNothing);
      await tap('Modo mezclado');
      await tap('Todos los bloques');
      expect(prompt(), orderedFirst);
      expect(find.text('Volver a mezclar'), findsNothing);
      expect(
        find.text(
          mixedFirst == orderedFirst ? 'My mixed draft.' : 'My ordered draft.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Translation hides references and keeps drafts across navigation and sections',
    (tester) async {
      await startApp(tester);
      await tester.tap(find.text('Traducción'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Frase 1 de 800'), findsOneWidget);
      expect(find.text('Traducción de referencia'), findsNothing);
      await tester.enterText(find.byType(TextField), 'My first draft.');
      await tester.ensureVisible(find.text('Mostrar traducción'));
      await tester.tap(find.text('Mostrar traducción'));
      await tester.pumpAndSettle();
      expect(find.text('Traducción de referencia'), findsOneWidget);
      expect(
        find.text(
          'I usually go to work by underground, but this week I am cycling.',
        ),
        findsOneWidget,
      );
      expect(find.text('Correcto'), findsNothing);
      expect(find.text('Incorrecto'), findsNothing);
      await tester.ensureVisible(find.text('Ocultar traducción'));
      await tester.tap(find.text('Ocultar traducción'));
      await tester.pumpAndSettle();
      expect(find.text('Traducción de referencia'), findsNothing);
      await tester.ensureVisible(find.text('Siguiente'));
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Frase 2 de 800'), findsOneWidget);
      expect(find.text('Traducción de referencia'), findsNothing);
      await tester.ensureVisible(find.text('Anterior'));
      await tester.tap(find.text('Anterior'));
      await tester.pumpAndSettle();
      expect(find.text('My first draft.'), findsOneWidget);
      await tester.tap(find.text('Grammar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Traducción'));
      await tester.pumpAndSettle();
      expect(find.text('My first draft.'), findsOneWidget);
      await tester.ensureVisible(find.text('Todos los bloques'));
      await tester.tap(find.text('Todos los bloques'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Presente simple y presente continuo').last);
      await tester.pumpAndSettle();
      expect(find.textContaining('Frase 1 de 32'), findsOneWidget);
      expect(find.text('My first draft.'), findsOneWidget);
      expect(find.text('Traducción de referencia'), findsNothing);
    },
  );

  testWidgets('Grammar is the initial view and can be checked with Enter', (
    tester,
  ) async {
    await startApp(tester);
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
    await startApp(tester);
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
      await startApp(tester);
      await tester.tap(find.text('Writing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cargar Writing'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Escribir'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).first,
        'A draft with español.',
      );
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
      await startApp(tester);
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
