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
  final writingCorrectionInput = TextEditingController();
  final writingScroll = ScrollController();
  List<WritingChange>? writingComparison;
  final vocabularyInput = TextEditingController();
  final translationInput = TextEditingController();
  final Map<String, String> translationDrafts = {};
  String translationTopic = '';
  List<dynamic> translationMixedItems = [];
  int translationIndex = 0;
  bool translationRevealed = false;
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
      for (final name in [
        'grammar',
        'reading',
        'writing',
        'vocabulary',
        'translation',
      ]) {
        data[name] = jsonDecode(
          await rootBundle.loadString('assets/data/$name.json'),
        );
      }
      try {
        preferences = await SharedPreferences.getInstance();
        progress = parseProgress(preferences!.getString('vocabulary-progress'));
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
    writingCorrectionInput.dispose();
    writingScroll.dispose();
    vocabularyInput.dispose();
    translationInput.dispose();
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
        LayoutBuilder(
          builder: (context, constraints) => Scrollbar(
            controller: writingScroll,
            thumbVisibility: constraints.maxWidth < 600,
            child: SingleChildScrollView(
              controller: writingScroll,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: max(600, constraints.maxWidth),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: writingPanel('Tu writing', writingInput, 'added'),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: writingPanel(
                        'Corrección',
                        writingCorrectionInput,
                        'removed',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (writingComparison != null) ...[
          const SizedBox(height: 12),
          if (writingComparison!.every((part) => part.kind == 'equal'))
            const Text('Sin diferencias.')
          else
            const Text('Eliminado: tachado · Añadido: subrayado'),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            action(
              writingComparison == null ? 'Comparar' : 'Editar textos',
              () {
                if (writingComparison != null) {
                  setState(() => writingComparison = null);
                  return;
                }
                if (writingInput.text.trim().isEmpty ||
                    writingCorrectionInput.text.trim().isEmpty) {
                  notice('Escribe tu writing y pega la corrección.');
                  return;
                }
                setState(
                  () => writingComparison = writingDiff(
                    writingInput.text,
                    writingCorrectionInput.text,
                  ),
                );
              },
            ),
            action('Guardar', saving ? null : saveWriting, primary: false),
          ],
        ),
      ],
    );
  }

  Widget writingPanel(
    String title,
    TextEditingController controller,
    String excluded,
  ) {
    if (writingComparison == null) {
      return field(
        controller,
        title == 'Corrección' ? 'Corrección (pegar texto)' : title,
        lines: 12,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xff59695e)),
          ),
          child: SelectableText.rich(
            TextSpan(
              style: const TextStyle(fontSize: 17, height: 1.8),
              children: [
                for (final part in writingComparison!.where(
                  (part) => part.kind != excluded,
                ))
                  TextSpan(
                    text: part.text,
                    style: part.kind == 'equal'
                        ? null
                        : TextStyle(
                            color: part.kind == 'removed'
                                ? const Color(0xffffaaa2)
                                : const Color(0xff8dd8af),
                            backgroundColor: part.kind == 'removed'
                                ? const Color(0xff4b252a)
                                : const Color(0xff173d2c),
                            decoration: part.kind == 'removed'
                                ? TextDecoration.lineThrough
                                : TextDecoration.underline,
                          ),
                  ),
              ],
            ),
          ),
        ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dificultad'),
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
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dirección'),
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
          ],
        ),
        const SizedBox(height: 24),
        if (storageWarning != null) Text(storageWarning!),
        if (item == null) ...[
          Text(
            'Próximo repaso: ${DateTime.fromMillisecondsSinceEpoch(saved.values.map((value) => (value['due'] as num).toInt()).reduce(min)).toLocal()}',
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

  List<dynamic> translationPool() => translationTopic == 'mixed'
      ? translationMixedItems
      : (sets!['translation']['items'] as List)
            .where(
              (item) =>
                  translationTopic.isEmpty || item['topic'] == translationTopic,
            )
            .toList();

  void changeTranslation({String? topic, int offset = 0}) {
    final current = translationPool()[translationIndex];
    translationDrafts[current['id'] as String] = translationInput.text;
    setState(() {
      if (topic != null) {
        translationTopic = topic;
        if (topic == 'mixed') {
          translationMixedItems = List.of(sets!['translation']['items'] as List)
            ..shuffle();
        }
        translationIndex = 0;
      } else {
        translationIndex += offset;
      }
      translationRevealed = false;
      final next = translationPool()[translationIndex];
      translationInput.text = translationDrafts[next['id']] ?? '';
    });
  }

  Widget translationView() {
    final pool = translationPool();
    final item = pool[translationIndex];
    final topics = (sets!['translation']['items'] as List)
        .map((item) => item['topic'] as String)
        .toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Traducción', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: translationTopic,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Modo / bloque'),
          items: [
            const DropdownMenuItem(value: '', child: Text('Todos los bloques')),
            const DropdownMenuItem(
              value: 'mixed',
              child: Text('Modo mezclado'),
            ),
            for (final topic in topics)
              DropdownMenuItem(
                value: topic,
                child: Text(topic, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) {
            if (value != null) changeTranslation(topic: value);
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Frase ${translationIndex + 1} de ${pool.length} · ${item['topic']}',
        ),
        const SizedBox(height: 16),
        SelectableText(
          item['spanish'] as String,
          style: const TextStyle(fontSize: 23, height: 1.6),
        ),
        field(translationInput, 'Tu traducción al inglés', lines: 3),
        action(
          translationRevealed ? 'Ocultar traducción' : 'Mostrar traducción',
          () => setState(() => translationRevealed = !translationRevealed),
        ),
        if (translationRevealed) ...[
          const SizedBox(height: 20),
          Text(
            'Traducción de referencia',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SelectableText(
            item['english'] as String,
            style: const TextStyle(fontSize: 20, height: 1.6),
          ),
          const SizedBox(height: 12),
          const Text('Puede haber otras traducciones correctas.'),
        ],
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            action(
              'Anterior',
              translationIndex == 0
                  ? null
                  : () => changeTranslation(offset: -1),
              primary: false,
            ),
            action(
              'Siguiente',
              translationIndex == pool.length - 1
                  ? null
                  : () => changeTranslation(offset: 1),
              primary: false,
            ),
            if (translationTopic == 'mixed')
              action(
                'Volver a mezclar',
                () => changeTranslation(topic: 'mixed'),
                primary: false,
              ),
          ],
        ),
      ],
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
                'Traducción',
              ])
                Expanded(
                  child: Semantics(
                    selected: section == name,
                    child: TextButton(
                      onPressed: sets == null
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
                            constraints: BoxConstraints(
                              maxWidth: section == 'Writing' ? 1200 : 750,
                            ),
                            child: switch (section) {
                              'Grammar' => grammarView(),
                              'Reading' => readingView(),
                              'Writing' => writingView(),
                              'Traducción' => translationView(),
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
