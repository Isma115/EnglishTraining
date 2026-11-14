# Paridad entre escritorio y móvil

- Las cinco vistas están disponibles en ambas versiones, con Grammar como vista inicial.
- Los cinco bancos se distribuyen idénticos y funcionan sin conexión.
- Grammar y Vocabulary aceptan las mismas variantes de respuestas: normalización Unicode NFKC, mayúsculas, espacios, apóstrofos tipográficos y puntuación final; se conservan los acentos.
- Vocabulary comparte el calendario de repetición espaciada, las dos dificultades y las dos direcciones. El progreso se conserva localmente por dirección y palabra; los registros inválidos se descartan y un documento de progreso ilegible muestra un aviso sin bloquear la práctica.
- Reading conserva las respuestas al regresar al texto o cambiar de vista y muestra referencias para comprobación manual.
- Writing conserva el original, la corrección pegada y la comparación durante la sesión. Compara ambos textos lado a lado con diferencias destacadas y permite volver a editarlos. Guarda el original en UTF-8 mediante el selector nativo, con confirmación de guardado y aviso de error.
- Traducción comparte bloques, contador, referencias ocultables, borradores, navegación y modo mezclado de las 800 frases, sin repeticiones dentro de cada ronda.
- Los controles se adaptan a cada plataforma manteniendo sus funciones; la navegación móvil identifica la vista seleccionada también para lectores de pantalla.
- La paridad de corrección, progreso y repasos se verifica con casos compartidos en `tests/fixtures/practice-parity.json`. La igualdad de los bancos y los flujos de interfaz también tienen pruebas automatizadas.
- Los borradores duran la sesión. El progreso se guarda por dispositivo; no hay sincronización entre dispositivos.
