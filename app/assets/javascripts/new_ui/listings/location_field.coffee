class @DNM.Listings.LocationField

  constructor: (field) ->
    @field = $(field)
    @options ||= => $('[data-location-actions] [data-location-id]')
    @bindEvents()

  bindEvents: =>
    @field.on 'change', =>
      location_id = @field.val()
      @options().attr('hidden', true).filter('[data-location-id="' + location_id + '"]').removeAttr('hidden')

$('[data-location-field]').each ->
  new DNM.Listings.LocationField(@)
