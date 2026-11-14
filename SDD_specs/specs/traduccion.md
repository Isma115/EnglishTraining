# Traducción de frases

- Apartado Traducción en el menú superior, disponible en Electron y Flutter sin conexión.
- 800 frases españolas y traducciones de referencia en inglés, agrupadas en 25 bloques gramaticales de 32 frases.
- Conjuntos idénticos en `data/translation.json` y `mobile/assets/data/translation.json`.
- Selector Modo / bloque: Todos los bloques y bloques individuales mantienen el orden original; Modo mezclado baraja todas las frases de todos los bloques sin repeticiones dentro de la ronda.
- Anterior/Siguiente recorre el orden seleccionado con contador. Volver a mezclar inicia una nueva ronda aleatoria desde la primera posición.
- El orden mezclado se conserva al mostrar u ocultar la referencia y al cambiar de apartado. Los borradores se conservan también al cambiar de modo o volver a mezclar.
- Campo para escribir una traducción propia. Los borradores se conservan por frase mientras la aplicación está abierta, incluso al cambiar de apartado o bloque.
- Mostrar traducción revela la referencia inglesa; Ocultar traducción permite volver a esconderla. Cambiar de frase o bloque oculta la referencia.
- Comprobación manual: pueden existir otras traducciones correctas. No se califica una frase como incorrecta por no coincidir literalmente con la referencia.
