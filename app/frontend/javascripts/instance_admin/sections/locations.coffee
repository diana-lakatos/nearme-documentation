urlUtil = require('../../lib/utils/url')

module.exports = class InstanceAdminLocationsController

  constructor: (@editLocationTypesForm) ->
    @bindEvents()

  bindEvents: ->
    inputs = @editLocationTypesForm.find('input.location-type-name')

    inputs.on 'focusin', (event) =>
      event.preventDefault()
      @currentValue = $(event.target).val()

    inputs.on 'focusout', (event) =>
      event.preventDefault()
      @updateLocationType(event)

    inputs.on 'keyup', (event) =>
      if event.keyCode == 13
        @updateLocationType(event)

    $('a[data-location-types-instance-admin-modal]').click (event) ->
      event.preventDefault()
      target = $(this).attr('href')
      $('#instanceAdminModal .modal-content').load target, ->
        $('#instanceAdminModal').modal 'show'
        return
      return

  updateLocationType: (event) =>
    self = $(event.target)
    modifiedValue = self.val()
    if (!!modifiedValue && !!@currentValue && modifiedValue != @currentValue)
      entry = self.closest('div.location-type-entry')
      locationTypeId = entry.find('input.location-type-id').val()

      $.ajax
        url: @editLocationTypesForm.attr('action').replace(':id', locationTypeId)
        type: 'PATCH'
        dataType: 'JSON'
        data: { location_type: {name: modifiedValue} }
        success: (data) =>
          @blinkImage(entry, data['success'])
        error: ->
          @blinkImage(entry, false)

    @currentValue = null


  blinkImage: (entry, success) ->
    image = if success then 'green-check' else 'x-red'
    img = $('<img>').attr('src', urlUtil("dashboard/#{image}.png")).hide()
    entry.append(img)
    img.fadeIn('slow', -> img.fadeOut('slow', -> img.remove()))

