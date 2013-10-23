class @RouteLink

  constructor: (@element) ->
    @locate()

  locate: ->
    return unless Modernizr.geolocation
    navigator.geolocation.getCurrentPosition((position) =>
      @latitude  = position.coords.latitude
      @longitude = position.coords.longitude

      @geocode()
    )

  geocode: =>
    geocoder = new google.maps.Geocoder()
    latLng = new google.maps.LatLng(@latitude, @longitude)

    geocoder.geocode({latLng: latLng}, (results, status) =>
      if(status == google.maps.GeocoderStatus.OK)
        @source = results[0].formatted_address
        @rewriteRouteLink()
    )

  rewriteRouteLink: ->
    destination = @element.data('destination')
    source = @source

    link = "//maps.google.com/?daddr=#{destination}&saddr=#{source}"
    @element.attr('href', link)
