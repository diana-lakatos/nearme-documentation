Modal = require('./modal')

module.exports = class ModalForm

  constructor: (@container, @form = @container) ->
    @focusInput()
    @bindEvents()
    if @insideModal()
      @updateModalOnSubmit()

  focusInput: =>
    if @form.find('.error-block').length > 0
      @form.find('.error-block').eq(0).siblings('input:visible').focus()
    else
      @form.find('input:visible').eq(0).focus()

  bindEvents: ->

  updateModalOnSubmit: =>
    @form.submit =>
      Modal.load({ type: "POST", url: @form.attr("action"), data: @form.serialize()})
      false

  insideModal: =>
    @container.closest('.modal-container.visible').length > 0
