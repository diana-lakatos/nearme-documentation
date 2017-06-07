// @flow
let els = document.querySelectorAll('.slider-a.transactables article');

if (els.length > 0) {
  let newCommentsLabel = require('../home/new_comments_label');
  Array.prototype.forEach.call(els, (el: HTMLElement) => {
    newCommentsLabel(el);
  });
}
