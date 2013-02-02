class DNM.LocationFinder
  constructor: (form) ->

    #subject
    @geoPosition = new DNM.UI.GeoPosition()

    #observers
    #map act as an observer and a modifier -> marker can be moved on the map
    map = new DNM.UI.Map({ anchor: form.find('.map .map-container'), icon: form.find('.map').attr('data-marker')}, @geoPosition)
    @geoRecord = new DNM.UI.GeoRecord({latitude: form.find('#latitude'), longitude: form.find('#longitude')})

    #registration
    @geoPosition.register(map)
    @geoPosition.register(@geoRecord)

    #initializer
    @setGeoCoords()

    #modifier
    geoFinder = new DNM.UI.GeoFinder(form.find('input.query'), @geoPosition)
    geoLocator = new DNM.UI.GeoLocator(form.find('.geolocation'), @geoPosition)


  setGeoCoords: ->
    lat = @geoRecord.getLatitude()
    lng =  @geoRecord.getLongitude()
    if (lat != 0 && lng != 0)
     @geoPosition.setPosition ({latitude: lat, longitude: lng})


