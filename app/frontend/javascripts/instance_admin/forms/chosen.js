var ChosenInitializer;

require('chosen-js/chosen.jquery');

ChosenInitializer = function() {
  function ChosenInitializer(context) {
    this.initialize(context);
  }

  ChosenInitializer.prototype.initialize = function(context) {
    if (context == null) {
      context = 'body';
    }
    $(context).find('select.chosen').chosen();
    return $(context).find('select.select:not(.select2)').chosen({ width: '100%' });
  };

  return ChosenInitializer;
}();

module.exports = ChosenInitializer;
