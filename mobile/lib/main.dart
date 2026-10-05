import 'dart:convert';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'practice.dart';

void main() => runApp(const PracticeApp());

class PracticeApp extends StatelessWidget {
  const PracticeApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Aquí tú me hablas español',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff245b46),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xff171b19),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: const RoundedRectangleBorder()),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: const RoundedRectangleBorder()),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: const RoundedRectangleBorder(),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 2),
        ),
      ),
      dialogTheme: const DialogThemeData(shape: RoundedRectangleBorder()),
      snackBarTheme: const SnackBarThemeData(shape: RoundedRectangleBorder()),
      useMaterial3: true,
    ),
    home: const PracticeHome(),
  );
}

class PracticeHome extends StatefulWidget {
  const PracticeHome({super.key});
  @override
  State<PracticeHome> createState() => _PracticeHomeState();
}

class _PracticeHomeState extends State<PracticeHome> {
  Map<String, dynamic>? sets;
  String? loadError;
  String? storageWarning;
  String section = 'Grammar';
  Map<String, dynamic>? grammar, reading, writing, vocabulary;
  final grammarInput = TextEditingController();
  final writingInput = TextEditingController();
  final vocabularyInput = TextEditingController();
  List<TextEditingController> readingInputs = [];
  bool grammarChecked = false,
      readingChecked = false,
      vocabularyChecked = false;
  bool readingQuestions = false, saving = false, reviewing = false;
  String difficulty = 'Frecuente', direction = 'en-es';
  Map<String, dynamic> progress = {};
  SharedPreferences? preferences;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = <String, dynamic>{};
      for (final name in ['grammar', 'reading', 'writing', 'vocabulary']) {
        data[name] = jsonDecode(
          await rootBundle.loadString('assets/data/$name.json'),
        );
      }
      try {
        preferences = await SharedPreferences.getInstance();
        progress = Map<String, dynamic>.from(
          jsonDecode(preferences!.getString('vocabulary-progress') ?? '{}')
              as Map,
        );
        progress.removeWhere(
          (key, value) =>
              value is! Map ||
              value['due'] is! num ||
              value['ease'] is! num ||
              value['interval'] is! num ||
              value['repetitions'] is! int,
        );
      } catch (_) {
        progress = {};
        storageWarning = 'No se pudo recuperar el progreso.';
      }
      if (!mounted) {
        return;
      }
      setState(() {
        sets = data;
        grammar = pick(data['grammar']['items'] as List);
      });
    } catch (_) {
      if (mounted) {
        setState(() => loadError = 'No se pudieron cargar los ejercicios.');
      }
    }
  }

  @override
  void dispose() {
    grammarInput.dispose();
    writingInput.dispose();
    vocabularyInput.dispose();
    for (final controller in readingInputs) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget action(String text, VoidCallback? callback, {bool primary = true}) =>
      primary
      ? FilledButton(onPressed: callback, child: Text(text))
      : OutlinedButton(onPressed: callback, child: Text(text));

  Widget field(
    TextEditingController controller,
    String label, {
    int lines = 1,
    ValueChanged<String>? onSubmitted,
    bool readOnly = false,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: TextField(
      controller: controller,
      readOnly: readOnly,
      minLines: lines,
      maxLines: lines == 1 ? 1 : null,
      autocorrect: false,
      textInputAction: lines == 1
          ? TextInputAction.done
          : TextInputAction.newline,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(labelText: label),
    ),
  );

  Widget feedback(bool correct, String answer) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        correct ? 'Correcto' : 'Incorrecto',
        style: TextStyle(
          color: correct ? const Color(0xff8dd8af) : const Color(0xffffaaa2),
        ),
      ),
      const SizedBox(height: 12),
      SelectableText(answer),
      const SizedBox(height: 24),
    ],
  );

  Widget grammarView() {
    final item = grammar!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item['prompt'] as String,
          style: const TextStyle(fontSize: 23, height: 1.6),
        ),
        field(
          grammarInput,
          'Completa la frase',
          readOnly: grammarChecked,
          onSubmitted: (_) => checkGrammar(),
        ),
        if (grammarChecked) ...[
          feedback(
            matches(grammarInput.text, item['answers'] as List),
            item['completed'] as String,
          ),
          action(
            'Siguiente',
            () => setState(() {
              grammar = pick(
                sets!['grammar']['items'] as List,
                item['id'] as String,
              );
              grammarInput.clear();
              grammarChecked = false;
            }),
          ),
        ] else
          action('Comprobar', checkGrammar),
      ],
    );
  }

  void checkGrammar() {
    if (!grammarChecked && grammarInput.text.trim().isNotEmpty) {
      FocusScope.of(context).unfocus();
      setState(() => grammarChecked = true);
    }
  }

  void newReading() {
    final oldId = reading?['id'] as String?;
    for (final controller in readingInputs) {
      controller.dispose();
    }
    reading = pick(sets!['reading']['items'] as List, oldId);
    readingInputs = (reading!['questions'] as List)
        .map((_) => TextEditingController())
        .toList();
    readingQuestions = false;
    readingChecked = false;
  }

  Widget readingView() {
    if (reading == null) {
      return Center(child: action('Hacer Reading', () => setState(newReading)));
    }
    final questions = reading!['questions'] as List;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reading!['title'] as String,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        if (!readingQuestions) ...[
          SelectableText(
            reading!['text'] as String,
            style: const TextStyle(fontSize: 17, height: 1.8),
          ),
          const SizedBox(height: 24),
          action('Siguiente', () => setState(() => readingQuestions = true)),
        ] else ...[
          for (var i = 0; i < questions.length; i++) ...[
            Text('${i + 1}. ${questions[i]['question']}'),
            field(readingInputs[i], 'Tu respuesta', lines: 2),
            if (readingChecked) ...[
              SelectableText(
                questions[i]['answer'] as String,
                style: const TextStyle(color: Color(0xff8dd8af)),
              ),
              const SizedBox(height: 24),
            ],
          ],
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              action('Comprobar', () => setState(() => readingChecked = true)),
              action(
                'Volver',
                () => setState(() => readingQuestions = false),
                primary: false,
              ),
              if (readingChecked)
                action(
                  'Hacer Reading',
                  () => setState(newReading),
                  primary: false,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> newWriting() async {
    setState(() => writing = pick(sets!['writing']['items'] as List));
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tema del writing: ${writing!['topic']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Escribir'),
          ),
        ],
      ),
    );
  }

  Future<void> saveWriting() async {
    if (writingInput.text.trim().isEmpty) {
      notice('Escribe un writing antes de guardar.');
      return;
    }
    setState(() => saving = true);
    try {
      final path = await FilePicker.saveFile(
        dialogTitle: 'Guardar Writing',
        fileName: 'writing.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
        bytes: Uint8List.fromList(utf8.encode(writingInput.text)),
      );
      if (mounted && path != null) notice('Guardado');
    } catch (_) {
      if (mounted) notice('No se pudo guardar el archivo.');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void notice(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Widget writingView() {
    if (writing == null) {
      return Center(child: action('Cargar Writing', newWriting));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(writing!['topic'] as String),
        field(writingInput, 'Tu writing', lines: 12),
        action('Guardar', saving ? null : saveWriting),
      ],
    );
  }

  List<dynamic> vocabularyPool() => (sets!['vocabulary']['items'] as List)
      .where((item) => item['difficulty'] == difficulty)
      .toList();

  Map<String, dynamic> cardProgress(List<dynamic> pool) => {
    for (final card in pool)
      if (progress['$direction:${card['id']}'] != null)
        card['id'] as String: progress['$direction:${card['id']}'],
  };

  void resetVocabulary() {
    vocabulary = null;
    vocabularyChecked = false;
    vocabularyInput.clear();
  }

  Future<void> checkVocabulary() async {
    if (reviewing || vocabularyChecked || vocabularyInput.text.trim().isEmpty) {
      return;
    }
    final item = vocabulary!;
    final accepted = direction == 'en-es'
        ? item['spanish'] as List
        : [item['english']];
    final key = '$direction:${item['id']}';
    final previous = progress[key] == null
        ? null
        : Map<String, dynamic>.from(progress[key] as Map);
    progress[key] = review(previous, matches(vocabularyInput.text, accepted));
    setState(() {
      vocabularyChecked = true;
      reviewing = true;
    });
    FocusScope.of(context).unfocus();
    try {
      preferences ??= await SharedPreferences.getInstance();
      if (!await preferences!.setString(
        'vocabulary-progress',
        jsonEncode(progress),
      )) {
        throw StateError('Save failed');
      }
      storageWarning = null;
    } catch (_) {
      storageWarning = 'No se pudo guardar el progreso.';
    } finally {
      if (mounted) setState(() => reviewing = false);
    }
  }

  Widget vocabularyView() {
    final pool = vocabularyPool();
    final saved = cardProgress(pool);
    vocabulary ??= nextCard(pool, saved);
    final item = vocabulary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 16,
          children: [
            DropdownButton<String>(
              value: difficulty,
              items: ['Frecuente', 'Menos frecuente']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: reviewing
                  ? null
                  : (value) => setState(() {
                      difficulty = value!;
                      resetVocabulary();
                    }),
            ),
            DropdownButton<String>(
              value: direction,
              items: const [
                DropdownMenuItem(
                  value: 'en-es',
                  child: Text('English → Español'),
                ),
                DropdownMenuItem(
                  value: 'es-en',
                  child: Text('Español → English'),
                ),
              ],
              onChanged: reviewing
                  ? null
                  : (value) => setState(() {
                      direction = value!;
                      resetVocabulary();
                    }),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (storageWarning != null) Text(storageWarning!),
        if (item == null) ...[
          Text(
            'Próximo repaso: ${DateTime.fromMillisecondsSinceEpoch(saved.values.map((value) => value['due'] as int).reduce(min)).toLocal()}',
          ),
          action('Actualizar', () => setState(resetVocabulary)),
        ] else ...[
          Text(
            direction == 'en-es'
                ? item['english'] as String
                : (item['spanish'] as List).first as String,
            style: const TextStyle(fontSize: 26),
          ),
          field(
            vocabularyInput,
            direction == 'en-es'
                ? 'Significado en español'
                : 'Significado en inglés',
            readOnly: vocabularyChecked,
            onSubmitted: (_) => checkVocabulary(),
          ),
          if (vocabularyChecked) ...[
            feedback(
              matches(
                vocabularyInput.text,
                direction == 'en-es'
                    ? item['spanish'] as List
                    : [item['english']],
              ),
              direction == 'en-es'
                  ? (item['spanish'] as List).join(' / ')
                  : item['english'] as String,
            ),
            action(
              'Siguiente',
              reviewing ? null : () => setState(resetVocabulary),
            ),
          ] else
            action('Comprobar', checkVocabulary),
        ],
      ],
    );
  }

  void settings() {
    final size = MediaQuery.sizeOf(context);
    final side = min(340.0, min(size.width - 48, size.height - 48));
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: SizedBox.square(
          dimension: side,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajustes',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                action('Cerrar', () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              for (final name in [
                'Grammar',
                'Reading',
                'Writing',
                'Vocabulary',
                'Ajustes',
              ])
                Expanded(
                  child: TextButton(
                    onPressed: name == 'Ajustes'
                        ? settings
                        : sets == null
                        ? null
                        : () => setState(() => section = name),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        name,
                        style: TextStyle(
                          fontWeight: section == name
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: loadError != null
                ? Center(child: Text(loadError!))
                : sets == null
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      key: ValueKey(section),
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: max(0, constraints.maxHeight - 48),
                        ),
                        child: Align(
                          alignment:
                              (section == 'Reading' && reading == null) ||
                                  (section == 'Writing' && writing == null)
                              ? Alignment.center
                              : Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 750),
                            child: switch (section) {
                              'Grammar' => grammarView(),
                              'Reading' => readingView(),
                              'Writing' => writingView(),
                              _ => vocabularyView(),
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}
