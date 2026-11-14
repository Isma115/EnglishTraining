# Vista de gramática

Serán ejercicios que mezclarán ejercicios de completado (con pregunta y respuesta)

El banco de gramática contiene 200 ejercicios de nivel B2. Cada ejercicio incluye
una frase con un solo hueco y, al lado, el verbo en infinitivo y una referencia
temporal entre paréntesis, por ejemplo `(work; now)`. El alumno escribe la forma
verbal adecuada. No se muestran opciones, tiempos verbales ni pistas gramaticales.
No se muestran párrafos separados con instrucciones repetidas.
El enunciado debe establecer los hechos y la secuencia temporal necesarios.
En ejercicios de modales se incluye el modal en la frase para evitar exigir que
el alumno adivine la intención. Por ejemplo: `Mia booked a table, but the restaurant
was empty. She need not ____ one. (book; yesterday)`.
Si dos formas son válidas con el mismo significado, ambas se aceptan en la
corrección, sin mostrarlas como opciones.
Los temas incluyen condicionales, tiempos perfectos, pasiva, estilo indirecto,
verbos modales y patrones con infinitivo o gerundio.

El contenido se mantiene en `scripts/grammar_content.py`; `scripts/generate_sets.py`
genera copias idénticas en `data/grammar.json` y `mobile/assets/data/grammar.json`.

Habrán un solo tipo de preguntas:

	- Completar frase, se pedirá que se complete una frase
			1º. Se le pone al usuario una frase para completar, escogida aleatoriamente del set de preguntas de gramática
			2º. El usuario la tratará de completar
			3º. Pulsará en el botón de comprobar o en la tecla de Enter que disparará el evento para corregir el ejercicio
			4º. Aparecerá debajo de la frase a completar, la misma frase pero corregida
			5º. Se mostrará si se ha acertado la frase completada o si no, y el usuario podrá pasar a la siguiente pregunta de completado
