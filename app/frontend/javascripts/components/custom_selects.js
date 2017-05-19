var CustomSelects;

require('jquery.customSelect/jquery.customSelect');

require('chosen-js/chosen.jquery');

require('select2/select2');

CustomSelects = function() {
  function CustomSelects(container) {
    if (container == null) {
      container = 'body';
    }
    container = $(container);

    /*
     * customSelect
     */
    container
      .find('select')
      .not(
        '.select2, .time-wrapper select, .custom-select, .recurring_select, .ordinary-select, .selectpicker, .locales_languages_select, .unstyled-select'
      )
      .customSelect();
    container
      .not('.buy-sell-theme')
      .find('.customSelect')
      .not('.checkout-select, .no-icon')
      .append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>')
      .closest('.controls')
      .css({ 'position': 'relative' });
    container.find('.customSelect').siblings('select').css({ 'margin': '0px', 'z-index': 1 });

    /*
     * chosen
     */
    container.find('.custom-select').chosen();
    container.find('.chzn-container-single a.chzn-single div').hide();
    container
      .find('.chzn-container-single, .chzn-container-multi')
      .append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>');
    container
      .find('.chzn-choices input')
      .focus(function() {
        return $(this).parent().parent().addClass('chzn-choices-active');
      })
      .blur(function() {
        return $(this).parent().parent().removeClass('chzn-choices-active');
      });

    /*
    #select2
     */
    container.find('select.select2').each(function() {
      var $select, defaults, options;
      $select = $(this);
      defaults = { minimumResultsForSearch: 20 };
      options = $.extend(defaults, { placeholder: $select.data('select2-placeholder') });
      return $select.select2(options);
    });
  }

  return CustomSelects;
}();

module.exports = CustomSelects;
