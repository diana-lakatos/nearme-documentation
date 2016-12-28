import NM from 'nm';
import xhr from '../../toolkit/xhr';

import FormComponent from 'form_component';
const serialize = require('form-serialize');
const inflection = require('inflection');
const indicator = require('../loading_indicator');

class NMForm {
  constructor(form){
    this._ui = {};
    this._ui.form = form;
    this._apiEndpoint = form.dataset.apiEndpoint;
    this._objectName = form.dataset.objectName;
    this._components = {};
    this._findComponents();

    this._bindEvents();
  }

  getObjectName() {
    return this._objectName;
  }

  _bindEvents(){
    this._ui.form.addEventListener('submit', (e)=>{
      if (this.validateForm() === false) {
        e.preventDefault();
        return false;
      }
      if (this._apiEndpoint) {
        e.preventDefault();
        this.sendForm();
      }
    });
  }

  _findComponents(){
    Array.prototype.forEach.call(this._ui.form.querySelectorAll('.form-group'), (el)=>{
      if (el.dataset.formComponentInitialized) {
        return;
      }

      el.dataset.formComponentInitialized = true;
      let component = new FormComponent(el, this);
      this._components[component.getName()] = component;
    });
  }

  getComponent(name) {
    if (this._components.hasOwnProperty(name)) {
      return this._components[name];
    }
  }

  getValue(name) {
    let data = this.serialize();

    if (!data.hasOwnProperty(this._objectName)) {
      throw new Error(`Unable to serialize form data for ${this._objectName}`);
    }

    data = data[this._objectName];

    if (data.hasOwnProperty(name)){
      return data[name];
    }

        /* try for association name */
    const associationName = `${inflection.singularize(name)}_ids`;
    if (data.hasOwnProperty(associationName)) {
      return data[associationName];
    }
  }

  serialize() {
    return serialize(this._ui.form, { hash: true, empty: true });
  }

  sendForm(){

    indicator.show();

    let url = this._apiEndpoint;
    let xhrOptions = {
      method: this._ui.form.method,
      contentType: 'application/vnd.api+json',
      data: new FormData(this._ui.form)
    };

    xhr(url, xhrOptions)
            .then(this._processSuccess.bind(this), this._processErrors.bind(this));
  }

  validateForm(){
    let flag = true;

    if (this._ui.errorList) {
      this._ui.form.removeChild(this._ui.errorList);
      delete this._ui.errorList;
    }

    for (let component in this._components) {
      if (this._components.hasOwnProperty(component)) {
        if (!component.validate()) {
          /* focus on first invalid component */
          if (flag) {
            component.focus();
            flag = false;
          }
        }
      }
    }

    return flag;
  }

  setError(message, name = ''){
    console.log(this._ui.errorList);
    if (!this._ui.errorList) {
      this._ui.errorList = document.createElement('ul');
      this._ui.errorList.classList.add('error-list');
      this._ui.form.insertBefore(this._ui.errorList, this._ui.form.firstChild);
    }

    const li = document.createElement('li');
    li.innerHTML = (name ? `${name}: ` : '') + message;

    this._ui.errorList.appendChild(li);
  }

  _processErrors(data) {
    indicator.hide();

    if (!data.errors) {
      return this.setError('General', 'Unable to save form');
    }

    data.errors.forEach((error)=>{
      let name = error.source.pointer.split('/').pop();
      const component = this.getComponent(name);
      if (component) {
        component.setError(error.detail);
      }
      else {
        this.setError(name, error.detail);
      }
    });
  }

  _processSuccess(data) {
    indicator.hide();

    if (data.meta && data.meta.message) {
      return NM.emit('create:notification', { type: 'success', message: data.meta.message });
    }
    if (data.meta && data.meta.redirect) {
      return window.location = data.meta.redirect;
    }

    return NM.emit('create:notification', { type: 'success', message: 'Your data was saved!' });
  }
}

module.exports = NMForm;
