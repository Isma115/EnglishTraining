(function (root) {
  const normalize = text => text.normalize('NFKC').toLowerCase().replace(/[’‘]/g, "'").replace(/\s+/g, ' ').trim().replace(/[.!?]+$/, '');
  const matches = (answer, accepted) => accepted.some(value => normalize(value) === normalize(answer));
  const pick = (items, previous, random = Math.random) => {
    const pool = items.length > 1 ? items.filter(item => item.id !== previous) : items;
    return pool[Math.floor(random() * pool.length)];
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
  const api = { normalize, matches, pick, review, nextCard };
  if (typeof module !== 'undefined') module.exports = api;
  else root.PracticeCore = api;
})(globalThis);
