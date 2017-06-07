// @flow

const CUTOFF_PERIOD = 7 * 24 * 60 * 60 * 1000; // one week
const LABEL_CLASS = 'new-comments-label';

function getLastCommentDate(dateString?: string): Date | void {
  if (!dateString) {
    return;
  }

  let timestamp = Date.parse(dateString);

  if (isNaN(timestamp)) {
    throw new Error(`Unable to parse provided date string: ${dateString}`);
  }

  return new Date(timestamp);
}

function checkPeriod(date: Date): boolean {
  let now = new Date();
  console.log(now.getTime() - date.getTime(), CUTOFF_PERIOD);
  return date.getTime() > now.getTime() - CUTOFF_PERIOD;
}

function newCommentsLabel(container: HTMLElement) {
  let lastCommentDate = getLastCommentDate(container.dataset.transactableLastCommentDate);

  if (lastCommentDate && checkPeriod(lastCommentDate)) {
    let anchor = container.querySelector('ul.numbers li');
    if (!(anchor instanceof HTMLElement)) {
      throw new Error('Missing comments anchor element');
    }

    anchor.insertAdjacentHTML('beforeend', `<span class="${LABEL_CLASS}">New</span>`);
  }
}

module.exports = newCommentsLabel;
