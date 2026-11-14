# EnglishTraining

Práctica sin conexión en Electron (escritorio) y Flutter (Android/iOS).

Ambas versiones incluyen Grammar, Reading, Writing, Vocabulary, Traducción. Comparten los cinco bancos de ejercicios; Traducción incluye 800 frases B2 y un modo mezclado sin repeticiones durante la ronda. Los borradores se mantienen al cambiar de vista durante la sesión. Writing se exporta como texto UTF-8 mediante el selector de archivos del sistema. El progreso de vocabulario se guarda localmente en cada dispositivo.

Para escritorio: `npm ci`, `npm start`. Para móvil se requiere Flutter compatible con Dart 3.13 o posterior; la validación local utiliza Flutter 3.47.7. Desde `mobile/`: `flutter pub get`, `flutter run`.

Comprobaciones antes de entregar cambios:

```text
npm test
cd mobile
flutter analyze
flutter test
```

Las pruebas de ambas versiones consumen los mismos casos de corrección, recuperación de progreso y repetición espaciada en `tests/fixtures/practice-parity.json`. También comprueban que los bancos de escritorio y móvil sean idénticos. Las pruebas de interfaz móvil cubren navegación, borradores, referencias, dificultad, dirección y modo mezclado.

El SDK auxiliar descargado para esta revisión está en `tmp/tooling/flutter/`, excluido de Git. No sustituye al SDK instalado en el sistema; puede usarse indicando la ruta completa a `bin/flutter.bat`.
