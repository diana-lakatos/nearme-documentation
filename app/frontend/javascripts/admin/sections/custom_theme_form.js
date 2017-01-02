import closest from '../toolkit/closest';

class CustomThemeForm {
  constructor(form){
    this._ui = {};
    this._ui.form = form;
    this._ui.enableSwitch = form.querySelector('[data-enable-switch]');
    this._ui.previewSwitch = form.querySelector('[data-preview-switch]');
    this._ui.previewSwitchWrapper = closest(this._ui.previewSwitch, '.form-group');
    this._bindEvents();
  }

  _bindEvents(){
    this._ui.enableSwitch.addEventListener('change', ()=>{
      if (this._ui.enableSwitch.checked) {
        this._ui.previewSwitchWrapper.classList.add('disabled');
        this._ui.previewSwitch.setAttribute('disabled', 'disabled');
      }
      else {
        this._ui.previewSwitchWrapper.classList.remove('disabled');
        this._ui.previewSwitch.removeAttribute('disabled');
      }
    });
  }
}

module.exports = CustomThemeForm;
