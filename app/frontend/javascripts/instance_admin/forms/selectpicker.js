var SelectpickerInitializer;

require('../../vendor/bootstrap-select');

SelectpickerInitializer = function() {
  function SelectpickerInitializer() {
    this.initialize();
  }

  SelectpickerInitializer.prototype.initialize = function() {
    return $('.selectpicker').selectpicker();
  };

  return SelectpickerInitializer;
}();

module.exports = SelectpickerInitializer;
