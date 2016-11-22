'use strict';

const Events = require('minivents/dist/minivents.commonjs');

class NM {
  constructor() {
    new Events(this);

    document.addEventListener('DOMContentLoaded', ()=> {
      this.emit('ready');
    });

    document.addEventListener('load', ()=> {
      this.emit('load');
    });
  }
}

window.NM = new NM();

module.exports = window.NM;
