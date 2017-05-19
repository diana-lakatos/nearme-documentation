var Select2Initializer;

require('select2/select2');

Select2Initializer = function() {
  function Select2Initializer() {
    this.initialize();
  }

  Select2Initializer.prototype.initialize = function() {
    return $('.select2').each(function() {
      var $select, defaults, options;
      $select = $(this);
      defaults = {
        minimumResultsForSearch: 20,
        create: true,
        width: '100%'
        /*
         * TODO uncomment after upgrade to version 4.0
         * tags: true
         */
      };
      options = $.extend(defaults, { placeholder: $select.data('select2-placeholder') });
      return $select.select2(options);
    });
  };

  return Select2Initializer;
}();

module.exports = Select2Initializer;
