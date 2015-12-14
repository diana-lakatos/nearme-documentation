class @DNM.Listings.LocationField

  constructor: (field) ->
    @field = $(field)
    @options ||= => $('[data-location-actions] [data-location-id]')
    @bindEvents()

  bindEvents: =>
    @field.on 'change', =>
      location_id = @field.val()
      option = @options().attr('hidden', true).filter('[data-location-id="' + location_id + '"]')
      option.removeAttr('hidden')
      $('label[for="availability_rules_defer"] p').text($(option).data('availability'))

    $('html').on 'loaded.dialog', ->
      $('.dialog--loaded [data-counter-limit]').each (index, item)=>
        new DNM.Limiter(item)
      new DNM.Listings.AvailabilityRules($('.dialog .listing-availability'))

$('[data-location-field]').each ->
  new DNM.Listings.LocationField(@)
