class @SpaceWizardSpaceForm

  constructor: (@container) ->
    @setupMap()

    @address = new AddressField(@container.find('[data-behavior=address-autocomplete]'))
    @address.onLocate (lat, lng) =>
      latlng = new google.maps.LatLng(lat, lng)

      @map.marker.setPosition(latlng)
      @mapContainer.show()
      google.maps.event.trigger(@map.map, 'resize')
      @map.map.setCenter(latlng)


  setupMap: ->
    @mapContainer = @container.find('.map')

    @map = { map: null, markers: [] }
    @map.map = SmartGoogleMap.createMap(@mapContainer.find('.map-container')[0], {
      zoom: 16,
      mapTypeControl: false,
      streetViewControl: false,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })

    @map.marker = new google.maps.Marker({
      map: @map.map,
      icon: @mapContainer.attr("data-marker"),
      draggable: true
    })

    # When the marker is dragged, update the lat/lng form position
    google.maps.event.addListener @map.marker, 'drag', =>
      position = @map.marker.getPosition()
      @address.setLatLng(position.lat(), position.lng())
