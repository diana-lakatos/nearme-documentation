//const delegate = require('dom-delegate');

class DomainRecordForm {
  constructor(form) {
    // All DOM elements should be added to _ui property
    this._ui = {};
    this._ui.form = form;

    this._delegated = {};
    // if you want to use event delegation uncomment the first line
    // and use it as follows for example:
    // this._delegated.form = delegate(this._ui.form);
    // this._delegated.form.on('click', '.some-input-inside', (e, target)=> { console.log(target); });
    // Add
    this._bindEvents();
  }

  _bindEvents() {}
}

module.exports = DomainRecordForm;
