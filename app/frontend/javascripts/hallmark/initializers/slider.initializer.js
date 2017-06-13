/* @flow */
let els = document.querySelectorAll('[data-slider]');

if (els.length > 0) {
  require.ensure('../slider/slider_factory', require => {
    const SliderFactory = require('../slider/slider_factory');
    Array.prototype.forEach.call(els, (el: HTMLElement) => {
      SliderFactory.create(el);
    });
  });
}
