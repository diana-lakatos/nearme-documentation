Modal = require('../../components/modal')
Dialog = require('../../dashboard/modules/dialog')

module.exports = class OverlappingReservationsController
  constructor: (@container, @review_options = {}) ->
    @dateField = @container.find('#order_dates')
    @visibleDateField = @container.find('.jquery-datepicker')
    @validatorUrl = @container.data('validator-url')
    @checkEnabled = @container.data('check-overlapping-dates')

  formAttributes: ->
    {
      date: @dateField.val()
    }

  checkNewDate: ->
    return true if @checkEnabled == undefined
    @clearWarnings()
    $.getJSON(@validatorUrl, @formAttributes()).then @handleResponse

  handleResponse: (response) =>
    return unless response.warnings
    warning = $('<div class="warning"></div>').html(response.warnings.overlaping_reservations)

    @displayMessage(warning)

  clearWarnings: () ->
    @visibleDateField.siblings('.warning').remove()

  displayMessage: (warning) ->
    @visibleDateField.parent().append(warning)
