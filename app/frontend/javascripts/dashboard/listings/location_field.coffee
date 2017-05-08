LimitedInput = require('../../components/limited_input')
AvailabilityRules = require('./availability_rules')

module.exports = class LocationField

  constructor: (field) ->
    @field = $(field)
    @options ||= -> $('[data-location-actions] [data-location-id]')
    @bindEvents()
    @locationChanged()

  bindEvents: =>
    @field.on 'change', =>
      @locationChanged()

    $('html').on 'loaded:dialog.nearme', ->
      $('.dialog--loaded [data-counter-limit]').each (index, item) ->
        new LimitedInput(item)
      new AvailabilityRules('.dialog .listing-availability')

  locationChanged: ->
    location_id = @field.val()
    option = @options().attr('hidden', true).filter('[data-location-id="' + location_id + '"]')
    option.removeAttr('hidden')
    $('label[for="availability_rules_defer"] p').text($(option).data('availability'))
