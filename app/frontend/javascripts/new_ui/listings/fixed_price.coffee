module.exports = class FixedPrice

  constructor: (container) ->
    @container = $(container)
    @freeCheckbox = @container.find('input[data-scheduled-action-free-booking]')
    @globalFreeCheckbox = $($.find('input[data-global-action-free-booking]'))
    @fixedPrice = @container.find('input[data-scheduled-fixed-price]')
    @bindEvents()

  bindEvents: ->
    @freeCheckbox.change (event) =>
      @freeCheckboxUpdated()

  freeCheckboxUpdated: ->
    @fixedPrice.prop('disabled', @freeCheckbox.is(':checked'))
    @updateGlobalFreeCheckbox()

  updateGlobalFreeCheckbox: ->
    if @freeCheckbox.prop('checked')
      @globalFreeCheckbox.val('1')
    else
      @globalFreeCheckbox.val('0')

