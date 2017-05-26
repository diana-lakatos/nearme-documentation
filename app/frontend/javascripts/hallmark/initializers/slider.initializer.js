/* @flow */
let els = document.querySelectorAll('[data-slider]');

if (els.length > 0) {
  require.ensure('../slider/slider', require => {
    const Slider = require('../slider/slider');
    Array.prototype.forEach.call(els, (el: HTMLElement) => {
      new Slider(el);
    });
  });
}
