class DNM.UI.Map
  constructor: (uiParams, geoPosition) ->
    @geoPosition = geoPosition
    @anchor = uiParams.anchor
    @map = { map: null, markers: [] }
    @map.map = SmartGoogleMap.createMap(@anchor[0], {
      zoom: 16,
      mapTypeControl: false,
      streetViewControl: false
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })

    @map.marker = new google.maps.Marker({
      map: @map.map,
      icon: uiParams.icon,
      draggable: true
    })

    # When the marker is dragged, update the lat/lng form position
    google.maps.event.addListener @map.marker, 'drag', =>
      position = @map.marker.getPosition()
      @geoPosition.setPosition({latitude: position.lat(), longitude: position.lng()})

  update: (geoPosition) =>
    latlng = new google.maps.LatLng(geoPosition.latitude, geoPosition.longitude)
    @map.marker.setPosition(latlng)
    @anchor.parent().show()
    google.maps.event.trigger(@map.map, 'resize')
    @map.map.setCenter(latlng)

