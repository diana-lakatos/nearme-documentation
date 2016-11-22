/**
 * Allows conditional display of fields in dashboard and space wizard
 * Requires an element with data-condition-field containing configuration in json format.
 *
 * Expected format:
 *
 * { "@value" : { "show": [], "hide": [] }, "default": { "show": [], "hide": [] }}
 *
 * @value - control value that triggers certain state
 * show and hide - array of selectors for fields that are supposed to be hidden / shown
 *
 * default - special entry that holds the state of controls when no other value is matched
 */
class ConditionField {
  /**
   * @param  {DOMElement} container DOM node wrapping the conditional input. Should have data-condition-field attribute
   */
  constructor(container){
    this._ui = {};
    this._ui.container = container;

    if (this._ui.container.dataset.initialised) {
      return;
    }
    this._ui.container.dataset.initialised = true;
    try {
      /* Remove surrounding quotes if any are added to JSON string */
      let conditions = this._ui.container.dataset.conditionField.replace(/^(?:"(.*)")|(?:'(.*)')$/,'$1$2');
      this.conditions = JSON.parse(conditions);
    }
    catch (e) {
      throw new TypeError('Unable to parse condition field parameters.');
    }

    this._bindEvents();
    this._init();
  }

  /**
   * @param  {String} value - Value for the condition field
   */
  applyConditionsForValue(value) {
    let condition;
    value = (value + '').toLowerCase();

    console.log(value);

    for (let prop in this.conditions) {
      if (this.conditions.hasOwnProperty(prop) && value === (prop+ '').toLowerCase()){
        condition = this.conditions[prop];
        break;
      }
    }

    if (!condition && this.conditions.hasOwnProperty('default')) {
      condition = this.conditions.default;
    }

    if (!condition) {
      return;
    }

    condition.hide.forEach((selector)=>{
      Array.prototype.forEach.call(document.querySelectorAll(selector), (el)=>{
        el.setAttribute('hidden', 'hidden');
        el.setAttribute('aria-hidden', true);
        this._disableFields(el);
      });
    });

    condition.show.forEach((selector)=>{
      Array.prototype.forEach.call(document.querySelectorAll(selector), (el)=>{
        el.removeAttribute('hidden');
        el.setAttribute('aria-hidden', false);
        this._enableFields(el);
      });
    });
  }

  /**
   * @param  {DOMElement} container Element holding form inputs to be disabled
   */
  _disableFields(container){
    Array.prototype.forEach.call(container.querySelectorAll('input, textarea, select'), (el)=>{
      this._persistDefaultDisabledState(el);
      el.disabled = true;
    });
  }

  /**
   * @param  {DOMElement} container Element with input fields that will be returned to their original disabled state
   * @return {[type]}
   */
  _enableFields(container){
    Array.prototype.forEach.call(container.querySelectorAll('input, textarea, select'), (el)=>{
      this._persistDefaultDisabledState(el);
      el.disabled = el.dataset.disabledOriginal === 'false' ? false : true;
    });
  }

  /**
   * @param  {DOMElement} el Input that will have it's state stored in data attribute
   */
  _persistDefaultDisabledState(el){
    if (typeof el.dataset.disabledOriginal === 'undefined') {
      el.dataset.disabledOriginal = el.disabled;
    }
  }

  _bindEvents() {

    let onUpdate = (event)=>{
      let value = this._getValueFromField(event.target);
      this.applyConditionsForValue(value);
    };

    this._ui.container.addEventListener('change', onUpdate);
    this._ui.container.addEventListener('input', onUpdate);
  }

  _getValueFromField(field) {
    let
      nodeName = field.nodeName.toLowerCase();

    if (field.type === 'radio' || field.type === 'checkbox') {
      return field.checked ? field.value : '';
    }
    else if (['input', 'select', 'textarea'].indexOf(nodeName) > -1) {
      return field.value;
    }
  }

  _init(){
    let fields = Array.prototype.filter.call(this._ui.container.querySelectorAll('input, textarea, select'), (field)=>{
      if ((field.type === 'radio' || field.type === 'checkbox') && !field.checked) {
        return false;
      }
      return true;
    });

    /* get value from last viable field or return empty */
    let value = fields.length > 0 ? this._getValueFromField(fields.pop) : '';
    this.applyConditionsForValue(value);
  }
}

module.exports = ConditionField;

