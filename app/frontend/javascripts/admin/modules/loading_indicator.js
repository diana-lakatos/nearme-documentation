const Spinner = require('spin.js');
import NM from 'nm';

let spinnerDefaults = {
  lines: 9,
  length: 0,
  width: 20,
  radius: 0,
  scale: 1,
  corners: 1,
  color: '#6d5cae',
  opacity: 0.05,
  rotate: 0,
  direction: 1,
  speed: 1,
  trail: 40,
  fps: 20,
  zIndex: 2000000000,
  className: 'spinner',
  top: '50%',
  left: '50%',
  shadow: false,
  hwaccel: true,
  // Whether to use hardware acceleration
  position: 'absolute'
};

class LoadingIndicator {
  constructor() {
    this._ui = {};
    this._build();
    this._bindEvents();
  }

  _build() {
    const el = document.createElement('div');
    el.className = 'loading-indicator';
    new Spinner(spinnerDefaults).spin(el);
    this._ui.element = el;
    document.body.appendChild(this._ui.element);
  }

  _bindEvents() {
    NM.on('show:loading_indicator', this.show.bind(this));
    NM.on('hide:loading_indicator', this.hide.bind(this));
  }

  show() {
    this._ui.element.classList.add('is-active');
  }

  hide() {
    this._ui.element.classList.remove('is-active');
  }
}

module.exports = new LoadingIndicator();
