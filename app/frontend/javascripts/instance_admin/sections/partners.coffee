module.exports = class InstanceAdminPartnersController

  constructor: (@form) ->
    @bindEvents()

  bindEvents: =>
    $('input[data-submit-add-theme]').on 'click', (event) =>
      event.preventDefault()

      $('<input>').attr(type: 'hidden', name: 'add_theme').val('1').appendTo(@form)
      @form.submit()

