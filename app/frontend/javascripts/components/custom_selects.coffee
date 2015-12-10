require('jquery.customSelect/jquery.customSelect');
require('chosen/chosen.jquery.min');
require('select2/select2');

module.exports = class CustomSelects
  @initialize: (container = 'body')->
    container = $(container)
    # customSelect
    container.find('select').not('.select2, .time-wrapper select, .custom-select, .recurring_select, .ordinary-select, .selectpicker').customSelect()
    container.find('.customSelect').not('.checkout-select, .no-icon').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>').closest('.controls').css({'position': 'relative'})
    container.find('.customSelect').siblings('select').css({'margin': '0px', 'z-index': 1 })

    # chosen
    container.find('.custom-select').chosen()
    container.find('.chzn-container-single a.chzn-single div').hide()
    container.find('.chzn-container-single, .chzn-container-multi').append('<i class="custom-select-dropdown-icon ico-chevron-down"></i>')
    container.find('.chzn-choices input').focus(()->
      $(this).parent().parent().addClass('chzn-choices-active')
    ).blur(()->
      $(this).parent().parent().removeClass('chzn-choices-active')
    )

    #select2
    container.find('.select2').select2({
        minimumResultsForSearch: 20
    });
