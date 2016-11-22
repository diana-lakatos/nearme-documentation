var conditionFields = document.querySelectorAll('[data-condition-field]');
if (conditionFields.length > 0) {
  require.ensure('../../form_components/condition_field', (require)=>{
    var ConditionField = require('../../form_components/condition_field');
    Array.prototype.forEach.call(conditionFields, (wrapper) => {
      new ConditionField(wrapper);
    });
  });
}
