const delegate = require('dom-delegate');
const initializeGeneralModules = require('general_modules');

import NM from 'nm';
import xhr from '../toolkit/xhr';
import injectHTML from '../toolkit/inject_html';
import loadingIndicator from 'loading_indicator';

class Dialog {
  constructor() {
    this._ui = {};
    this._bodyDelegated = delegate(document.body);
    this._build();
    this._bindEvents();
  }

  _build(){
    let dialog = document.createElement('div');
    dialog.className = 'dialog';
    dialog.setAttribute('role','dialog');
    dialog.setAttribute('aria-hidden', true);
    dialog.setAttribute('aria-describedby', 'dialog-title');
    dialog.setAttribute('tabindex', '-1');
    dialog.innerHTML = '<div class="dialog-overlay"></div><div class="dialog-container"><div class="dialog-content"></div><button type="button" data-modal-close class="dialog-close">Close</button></div>';

    this._ui.dialog = dialog;
    document.body.appendChild(this._ui.dialog);
    this._ui.overlay = this._ui.dialog.querySelector('.dialog-overlay');
    this._ui.contentHolder = this._ui.dialog.querySelector('.dialog-content');
  }

  _bindEvents(){
    delegate(this._ui.dialog).on('click', '[data-modal-close]', (e)=>{
      e.preventDefault();
      this.close();
    });

        /* Click on modal button trigger */
    this._bodyDelegated.on('click', 'a[data-modal]', (e, target) => {
      e.preventDefault();
      e.stopPropagation();
      this._load(target.href, {}, target.getAttribute('data-modal-class'));
    });

        /* submit form via button */
    this._bodyDelegated.on('submit', 'form[data-modal]', (e, form) =>{
      e.preventDefault();
      let xhrOptions = { method: form.method, body: new FormData(form) };
      this.load(form.action, xhrOptions, form.getAttribute('data-modal-class'));
    });

    this._ui.overlay.addEventListener('click', this.close.bind(this) );
  }

  load(url, xhrOptions = {}, klass = '') {
    xhrOptions.credentials = 'same-origin';

    this._showLoading();

    xhr(url, xhrOptions)
            .then((data)=>{
              NM.emit('loaded:dialog', data);
              this.open(data, klass);
            }).catch((ex)=>{
              this.open(ex);
            });
  }

  open(content, klass = '') {
    this._setContent(content);
    this._setClass(klass);
    this._show();
    NM.emit('opened:dialog');
  }

  getContentElement() {
    return this._ui.contentHolder;
  }

  _show() {
    this._focusElement = document.activeElement;
    document.body.classList.add('dialog-visible');
    this._ui.dialog.setAttribute('aria-hidden', false);
    this._ui.dialog.focus();

    this._bindEscapeKey();
  }

  _showLoading() {
    loadingIndicator.show();
  }

  _setContent(content){
    injectHTML(this._ui.contentHolder, content);
    initializeGeneralModules(this._ui.contentHolder);
    loadingIndicator.hide();
  }

  close(){
    this._ui.dialog.setAttribute('aria-hidden', true);
    document.body.classList.remove('dialog-visible');
    this._bodyDelegated.off('keydown');
    this._focusElement.focus();

    NM.emit('closed:dialog');
  }

  _bindEscapeKey(){
    this._bodyDelegated.on('keydown', (e)=>{
      if (e.which === 27) {
        this.close();
      }
    });
  }

  _setClass(klass = '') {
        /* Remove previous custom class if it's set on modal */
    if (this._customClass) {
      this._ui.dialog.classList.remove(this._customClass);
    }

    if (!klass) {
      return;
    }
    this._customClass = klass;
    this._ui.dialog.classList.add(klass);
  }
}

module.exports = new Dialog();
