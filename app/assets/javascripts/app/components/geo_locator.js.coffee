class DNM.UI.GeoLocator
  constructor: (anchor, geoPosition) ->
    @geocoder = new DNM.Geocoder()
    @anchor = anchor
    @geoPosition = geoPosition
    @bindEvents()
 
  bindEvents: ->
    @anchor.bind 'click', =>
      @geolocateMe()

  geolocateMe: ->
    return unless Modernizr.geolocation
    navigator.geolocation.getCurrentPosition (position) =>
      deferred = @geocoder.reverseGeocodeLatLng(position.coords.latitude, position.coords.longitude)
      deferred.done (resultset) =>
        address = resultset.getBestResult().result.formatted_address
        @geoPosition.setAddress(address)
        @geoPosition.setPosition(position.coords)
