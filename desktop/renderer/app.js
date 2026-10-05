const { matches, pick, review, nextCard } = PracticeCore;
const main = document.querySelector('#content');
let sets, view = 'grammar', grammar, grammarAnswer = '', grammarChecked = false;
let reading, readingStage = 'text', readingAnswers = [], readingChecked = false;
let writing, writingText = '', vocabulary, vocabularyAnswer = '', vocabularyChecked = false;
let difficulty = 'Frecuente', direction = 'en-es', progress = {}, storageWarning = '';
try { progress = JSON.parse(localStorage.getItem('vocabulary-progress') || '{}'); } catch { storageWarning = 'No se pudo recuperar el progreso.'; }
if (!progress || Array.isArray(progress) || typeof progress !== 'object') progress = {};
for (const [id, card] of Object.entries(progress)) {
  if (!card || !Number.isFinite(card.due) || !Number.isFinite(card.ease) || !Number.isFinite(card.interval) || !Number.isInteger(card.repetitions)) delete progress[id];
}

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
  ({ grammar: renderGrammar, reading: renderReading, writing: renderWriting, vocabulary: renderVocabulary })[view]();
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
  const { wrapper, field } = input('Tu writing', writingText, value => writingText = value, true);
  field.classList.add('writing'); main.append(wrapper);
  const status = element('p'); status.setAttribute('role', 'status');
  const save = button('Guardar', async () => {
    if (!writingText.trim()) { status.textContent = 'Escribe un writing antes de guardar.'; field.focus(); return; }
    save.disabled = true;
    try { status.textContent = await window.practice.saveWriting(writingText) ? 'Guardado' : ''; }
    catch { status.textContent = 'No se pudo guardar el archivo.'; }
    finally { save.disabled = false; }
  }, true);
  main.append(save, status);
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
document.querySelector('#settings-open').addEventListener('click', () => document.querySelector('#settings').showModal());
window.practice.loadSets().then(data => { sets = data; render(); }).catch(() => { main.replaceChildren(element('p', 'No se pudieron cargar los ejercicios.')); });
