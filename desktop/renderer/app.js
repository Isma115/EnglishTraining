const { matches, parseProgress, pick, shuffle, review, nextCard, writingDiff } = PracticeCore;
const main = document.querySelector('#content');
let sets, view = 'grammar', grammar, grammarAnswer = '', grammarChecked = false;
let reading, readingStage = 'text', readingAnswers = [], readingChecked = false;
let writing, writingText = '', vocabulary, vocabularyAnswer = '', vocabularyChecked = false;
let writingCorrection = '', writingComparison = null;
let translationTopic = '', translationIndex = 0, translationRevealed = false;
let translationMixedItems = [];
const translationDrafts = {};
let difficulty = 'Frecuente', direction = 'en-es', progress = {}, storageWarning = '';
try { progress = parseProgress(localStorage.getItem('vocabulary-progress')); } catch { storageWarning = 'No se pudo recuperar el progreso.'; }

function element(tag, text, className) {
  const node = document.createElement(tag);
  if (text !== undefined) node.textContent = text;
  if (className) node.className = className;
  return node;
}
function button(text, action, primary = false) {
  const node = element('button', text, primary ? 'primary' : '');
  node.addEventListener('click', action);
  return node;
}
function input(label, value, onInput, multiline = false) {
  const wrapper = element('label', label);
  const field = element(multiline ? 'textarea' : 'input');
  field.value = value; field.spellcheck = false; field.autocomplete = 'off';
  field.addEventListener('input', () => onInput(field.value));
  wrapper.append(field);
  return { wrapper, field };
}
function submitForm(fieldWrapper, callback) {
  const form = element('form');
  form.append(fieldWrapper);
  const submit = element('button', 'Comprobar', 'primary'); submit.type = 'submit'; form.append(submit);
  form.addEventListener('submit', event => { event.preventDefault(); callback(); });
  return form;
}
function render() {
  main.replaceChildren();
  document.querySelectorAll('[data-view]').forEach(node => {
    if (node.dataset.view === view) node.setAttribute('aria-current', 'page');
    else node.removeAttribute('aria-current');
  });
  ({ grammar: renderGrammar, reading: renderReading, writing: renderWriting, vocabulary: renderVocabulary, translation: renderTranslation })[view]();
}
function changeTranslationTopic(topic) {
  translationTopic = topic;
  if (topic === 'mixed') translationMixedItems = shuffle(sets.translation.items);
  translationIndex = 0; translationRevealed = false; render();
}
function renderTranslation() {
  main.append(element('h1', 'Traducción'));
  const toolbar = element('div', undefined, 'toolbar');
  const label = element('label', 'Modo / bloque '), select = element('select');
  select.setAttribute('aria-label', 'Modo / bloque');
  const topics = [...new Set(sets.translation.items.map(item => item.topic))];
  for (const topic of ['', 'mixed', ...topics]) {
    const option = element('option', topic === 'mixed' ? 'Modo mezclado' : topic || 'Todos los bloques');
    option.value = topic; select.append(option);
  }
  select.value = translationTopic;
  select.addEventListener('change', () => changeTranslationTopic(select.value));
  label.append(select); toolbar.append(label); main.append(toolbar);
  const pool = translationTopic === 'mixed' ? translationMixedItems
    : sets.translation.items.filter(item => !translationTopic || item.topic === translationTopic);
  const item = pool[translationIndex];
  main.append(element('p', `Frase ${translationIndex + 1} de ${pool.length} · ${item.topic}`));
  main.append(element('p', item.spanish, 'sentence'));
  const { wrapper, field } = input('Tu traducción al inglés', translationDrafts[item.id] || '', value => translationDrafts[item.id] = value, true);
  field.lang = 'en'; main.append(wrapper);
  const answer = element('section'); answer.id = 'translation-reference'; answer.lang = 'en';
  answer.hidden = !translationRevealed;
  answer.append(element('h2', 'Traducción de referencia'), element('p', item.english, 'sentence'));
  answer.querySelector('h2').lang = 'es';
  const reveal = button(translationRevealed ? 'Ocultar traducción' : 'Mostrar traducción', () => {
    translationRevealed = !translationRevealed; render();
    main.querySelector('[aria-controls="translation-reference"]').focus();
  }, true);
  reveal.setAttribute('aria-expanded', String(translationRevealed));
  reveal.setAttribute('aria-controls', answer.id);
  main.append(reveal, answer);
  if (translationRevealed) main.append(element('p', 'Puede haber otras traducciones correctas.'));
  const actions = element('div', undefined, 'actions');
  for (const [text, offset] of [['Anterior', -1], ['Siguiente', 1]]) {
    const move = button(text, () => {
      translationIndex += offset; translationRevealed = false; render();
      main.querySelector('textarea').focus();
    });
    move.disabled = translationIndex + offset < 0 || translationIndex + offset >= pool.length;
    actions.append(move);
  }
  if (translationTopic === 'mixed') actions.append(button('Volver a mezclar', () => changeTranslationTopic('mixed')));
  main.append(actions);
}
function renderGrammar() {
  grammar ||= pick(sets.grammar.items);
  main.append(element('p', grammar.prompt, 'sentence'));
  if (!grammarChecked) {
    const { wrapper, field } = input('Completa la frase', grammarAnswer, value => grammarAnswer = value);
    main.append(submitForm(wrapper, () => {
      if (!grammarAnswer.trim()) { field.focus(); return; }
      grammarChecked = true; render();
    })); field.focus();
  } else {
    const correct = matches(grammarAnswer, grammar.answers);
    main.append(element('p', grammarAnswer), element('p', correct ? 'Correcto' : 'Incorrecto', correct ? 'correct' : 'incorrect'), element('p', grammar.completed));
    main.append(button('Siguiente', () => { grammar = pick(sets.grammar.items, grammar.id); grammarAnswer = ''; grammarChecked = false; render(); }, true));
  }
}
function renderReading() {
  if (!reading) {
    const center = element('div', undefined, 'center');
    center.append(button('Hacer Reading', () => { reading = pick(sets.reading.items); readingAnswers = reading.questions.map(() => ''); render(); }, true));
    main.append(center); return;
  }
  main.append(element('h1', reading.title));
  if (readingStage === 'text') {
    const article = element('article', reading.text); article.lang = 'en'; main.append(article);
    main.append(button('Siguiente', () => { readingStage = 'questions'; render(); }, true));
  } else {
    reading.questions.forEach((question, index) => {
      const block = element('div', undefined, 'question');
      const { wrapper } = input(`${index + 1}. ${question.question}`, readingAnswers[index], value => readingAnswers[index] = value, true);
      block.append(wrapper);
      if (readingChecked) block.append(element('p', question.answer, 'correct'));
      main.append(block);
    });
    const actions = element('div', undefined, 'actions');
    actions.append(button('Comprobar', () => { readingChecked = true; render(); }, true), button('Volver', () => { readingStage = 'text'; render(); }));
    if (readingChecked) actions.append(button('Hacer Reading', () => { reading = pick(sets.reading.items, reading.id); readingAnswers = reading.questions.map(() => ''); readingChecked = false; readingStage = 'text'; render(); }));
    main.append(actions);
  }
}
function renderWriting() {
  if (!writing) {
    const center = element('div', undefined, 'center');
    center.append(button('Cargar Writing', () => {
      writing = pick(sets.writing.items); render();
      const popup = element('dialog'); popup.append(element('h2', `Tema del writing: ${writing.topic}`));
      popup.append(button('Escribir', () => popup.close(), true));
      popup.addEventListener('close', () => { popup.remove(); main.querySelector('textarea').focus(); }, { once: true });
      document.body.append(popup); popup.showModal();
    }, true)); main.append(center); return;
  }
  main.append(element('p', writing.topic));
  const scroll = element('div', undefined, 'writing-scroll');
  const columns = element('div', undefined, 'writing-columns');
  for (const [title, value, changed, excluded] of [
    ['Tu writing', writingText, value => writingText = value, 'added'],
    ['Corrección (pegar texto)', writingCorrection, value => writingCorrection = value, 'removed'],
  ]) {
    const panel = element('section'); panel.lang = 'en';
    if (writingComparison) {
      const heading = element('h2', title === 'Tu writing' ? title : 'Corrección'); heading.lang = 'es';
      const text = element('p', undefined, 'writing-diff');
      for (const part of writingComparison.filter(part => part.kind !== excluded)) {
        text.append(element(part.kind === 'removed' ? 'del' : part.kind === 'added' ? 'ins' : 'span', part.text));
      }
      panel.append(heading, text);
    } else {
      const { wrapper, field } = input(title, value, changed, true);
      wrapper.lang = 'es'; field.lang = 'en'; field.classList.add('writing'); panel.append(wrapper);
    }
    columns.append(panel);
  }
  scroll.append(columns); main.append(scroll);
  const actions = element('div', undefined, 'actions');
  actions.append(button(writingComparison ? 'Editar textos' : 'Comparar', () => {
    if (writingComparison) { writingComparison = null; render(); return; }
    if (!writingText.trim() || !writingCorrection.trim()) { status.textContent = 'Escribe tu writing y pega la corrección.'; return; }
    writingComparison = writingDiff(writingText, writingCorrection); render();
  }, true));
  if (writingComparison) {
    const legend = element('p');
    if (writingComparison.every(part => part.kind === 'equal')) legend.textContent = 'Sin diferencias.';
    else legend.append(element('del', 'Eliminado'), element('span', ' · '), element('ins', 'Añadido'));
    main.append(legend);
  }
  const status = element('p'); status.setAttribute('role', 'status');
  const save = button('Guardar', async () => {
    if (!writingText.trim()) { status.textContent = 'Escribe un writing antes de guardar.'; main.querySelector('textarea').focus(); return; }
    save.disabled = true;
    try { status.textContent = await window.practice.saveWriting(writingText) ? 'Guardado' : ''; }
    catch { status.textContent = 'No se pudo guardar el archivo.'; }
    finally { save.disabled = false; }
  }, true);
  actions.append(save); main.append(actions, status);
}
function renderVocabulary() {
  const toolbar = element('div', undefined, 'toolbar');
  for (const [label, values, selected, changed] of [
    ['Dificultad', ['Frecuente', 'Menos frecuente'], difficulty, value => difficulty = value],
    ['Dirección', ['en-es', 'es-en'], direction, value => direction = value],
  ]) {
    const wrapper = element('label', `${label} `), select = element('select');
    values.forEach(value => { const option = element('option', value === 'en-es' ? 'English → Español' : value === 'es-en' ? 'Español → English' : value); option.value = value; select.append(option); });
    select.value = selected;
    select.addEventListener('change', () => { changed(select.value); vocabulary = null; vocabularyAnswer = ''; vocabularyChecked = false; render(); });
    wrapper.append(select); toolbar.append(wrapper);
  }
  main.append(toolbar);
  const pool = sets.vocabulary.items.filter(item => item.difficulty === difficulty);
  const keyedProgress = Object.fromEntries(pool.filter(item => progress[`${direction}:${item.id}`]).map(item => [item.id, progress[`${direction}:${item.id}`]]));
  vocabulary ||= nextCard(pool, keyedProgress);
  if (storageWarning) main.append(element('p', storageWarning, 'incorrect'));
  if (!vocabulary) {
    const due = Math.min(...pool.filter(item => keyedProgress[item.id]).map(item => keyedProgress[item.id].due));
    main.append(element('p', `Próximo repaso: ${new Date(due).toLocaleString('es')}`), button('Actualizar', render)); return;
  }
  const accepted = direction === 'en-es' ? vocabulary.spanish : [vocabulary.english];
  main.append(element('p', direction === 'en-es' ? vocabulary.english : vocabulary.spanish[0], 'sentence'));
  if (!vocabularyChecked) {
    const { wrapper, field } = input(direction === 'en-es' ? 'Significado en español' : 'Significado en inglés', vocabularyAnswer, value => vocabularyAnswer = value);
    main.append(submitForm(wrapper, () => {
      if (!vocabularyAnswer.trim()) { field.focus(); return; }
      const key = `${direction}:${vocabulary.id}`;
      progress[key] = review(progress[key], matches(vocabularyAnswer, accepted));
      try { localStorage.setItem('vocabulary-progress', JSON.stringify(progress)); storageWarning = ''; }
      catch { storageWarning = 'No se pudo guardar el progreso.'; }
      vocabularyChecked = true; render();
    })); field.focus();
  } else {
    const correct = matches(vocabularyAnswer, accepted);
    main.append(element('p', correct ? 'Correcto' : 'Incorrecto', correct ? 'correct' : 'incorrect'), element('p', accepted.join(' / ')));
    main.append(button('Siguiente', () => { vocabulary = null; vocabularyAnswer = ''; vocabularyChecked = false; render(); }, true));
  }
}
document.querySelectorAll('[data-view]').forEach(node => node.addEventListener('click', () => { if (!sets) return; view = node.dataset.view; render(); }));
window.practice.loadSets().then(data => { sets = data; render(); }).catch(() => { main.replaceChildren(element('p', 'No se pudieron cargar los ejercicios.')); });
