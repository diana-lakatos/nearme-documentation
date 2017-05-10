require('jquery.customSelect/jquery.customSelect')
require('chosen-js/chosen.jquery')
require('select2/select2')

module.exports = class CustomSelects
  constructor: (container = 'body') ->
    container = $(container)
    # customSelect
    container.find('select').not('.select2, .time-wrapper select, .custom-select, .recurring_select, .ordinary-select, .selectpicker, .locales_languages_select, .unstyled-select').customSelect()
    container.not('.buy-sell-theme').find('.customSelect').not('.checkout-select, .no-icon').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>').closest('.controls').css({'position': 'relative'})
    container.find('.customSelect').siblings('select').css({'margin': '0px', 'z-index': 1 })

    # chosen
    container.find('.custom-select').chosen()
    container.find('.chzn-container-single a.chzn-single div').hide()
    container.find('.chzn-container-single, .chzn-container-multi').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>')
    container.find('.chzn-choices input').focus(->
      $(this).parent().parent().addClass('chzn-choices-active')
    ).blur(->
      $(this).parent().parent().removeClass('chzn-choices-active')
    )

    #select2

    container.find('select.select2').each ->
      $select = $(this)

      defaults = {
        minimumResultsForSearch: 20
      }

      options = $.extend(defaults, {
        placeholder: $select.data('select2-placeholder')
      })

      $select.select2(options)
