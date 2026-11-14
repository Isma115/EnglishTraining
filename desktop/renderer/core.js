(function (root) {
  const normalize = text => text.normalize('NFKC').toLowerCase().replace(/[’‘]/g, "'").replace(/\s+/g, ' ').trim().replace(/[.!?]+$/, '');
  const matches = (answer, accepted) => accepted.some(value => normalize(value) === normalize(answer));
  const parseProgress = text => {
    const progress = JSON.parse(text ?? '{}');
    if (!progress || Array.isArray(progress) || typeof progress !== 'object') throw new Error('Invalid vocabulary progress');
    for (const [id, card] of Object.entries(progress)) {
      if (!card || !Number.isFinite(card.due) || !Number.isFinite(card.ease) || !Number.isFinite(card.interval) || !Number.isInteger(card.repetitions)) delete progress[id];
    }
    return progress;
  };
  const pick = (items, previous, random = Math.random) => {
    const pool = items.length > 1 ? items.filter(item => item.id !== previous) : items;
    return pool[Math.floor(random() * pool.length)];
  };
  const shuffle = (items, random = Math.random) => {
    const shuffled = [...items];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  };
  // Graduated intervals: a failed recall returns after a minute; successful recalls
  // grow from one day to three days, then by the card's ease factor.
  const review = (previous, correct, now = Date.now()) => {
    const state = previous || { repetitions: 0, interval: 0, ease: 2.5 };
    const ease = Math.max(1.3, state.ease + (correct ? 0.1 : -0.2));
    const interval = correct ? (state.repetitions === 0 ? 1 : state.repetitions === 1 ? 3 : Math.round(state.interval * ease)) : 0;
    return { repetitions: correct ? state.repetitions + 1 : 0, interval, ease, due: now + (correct ? interval * 86400000 : 60000) };
  };
  const nextCard = (cards, progress, previous, now = Date.now()) => {
    const due = cards.filter(card => progress[card.id] && progress[card.id].due <= now);
    if (due.length) return due.sort((a, b) => progress[a.id].due - progress[b.id].due)[0];
    const fresh = cards.filter(card => !progress[card.id]);
    return fresh.length ? pick(fresh, previous) : null;
  };
  const writingDiff = (original, corrected) => {
    const tokens = text => text.match(/\s+|[^\s.,!?;:()[\]{}"'“”‘’—–-]+|[^\s]/gu) || [];
    const changes = [];
    const emit = (kind, parts) => {
      const text = parts.join('');
      if (!text) return;
      if (changes.at(-1)?.kind === kind) changes.at(-1).text += text;
      else changes.push({ kind, text });
    };
    // Hirschberg's LCS keeps memory linear in the text length.
    const lengths = (a, b) => {
      let row = new Uint32Array(b.length + 1);
      for (const token of a) {
        const next = new Uint32Array(b.length + 1);
        for (let j = 0; j < b.length; j++) next[j + 1] = token === b[j] ? row[j] + 1 : Math.max(row[j + 1], next[j]);
        row = next;
      }
      return row;
    };
    const compare = (a, b) => {
      let prefix = 0, suffix = 0;
      while (prefix < a.length && prefix < b.length && a[prefix] === b[prefix]) prefix++;
      emit('equal', a.slice(0, prefix));
      a = a.slice(prefix); b = b.slice(prefix);
      while (suffix < a.length && suffix < b.length && a[a.length - 1 - suffix] === b[b.length - 1 - suffix]) suffix++;
      const tail = a.slice(a.length - suffix);
      a = a.slice(0, a.length - suffix); b = b.slice(0, b.length - suffix);
      const words = new Set(a);
      if (!a.length || !b.length || !b.some(word => words.has(word))) {
        emit('removed', a); emit('added', b);
      } else if (a.length === 1) {
        const index = b.indexOf(a[0]);
        emit('added', b.slice(0, index)); emit('equal', a); emit('added', b.slice(index + 1));
      } else {
        const middle = Math.floor(a.length / 2);
        const left = lengths(a.slice(0, middle), b);
        const right = lengths(a.slice(middle).reverse(), [...b].reverse());
        let split = 0;
        for (let j = 1; j <= b.length; j++) if (left[j] + right[b.length - j] > left[split] + right[b.length - split]) split = j;
        compare(a.slice(0, middle), b.slice(0, split));
        compare(a.slice(middle), b.slice(split));
      }
      emit('equal', tail);
    };
    compare(tokens(original), tokens(corrected));
    return changes;
  };
  const api = { normalize, matches, parseProgress, pick, shuffle, review, nextCard, writingDiff };
  if (typeof module !== 'undefined') module.exports = api;
  else root.PracticeCore = api;
})(globalThis);
