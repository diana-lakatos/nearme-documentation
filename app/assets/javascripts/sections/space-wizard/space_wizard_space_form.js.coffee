class @SpaceWizardSpaceForm

  constructor: (@container) ->
    @setupMap()
    @address = new AddressAutocomplete(@container.find('[data-behavior=address-autocomplete]'))
    @address.onLocate (lat, lng) =>
      latlng = new google.maps.LatLng(lat, lng)

      @map.marker.setPosition(latlng)
      @mapContainer.show()
      google.maps.event.trigger(@map.map, 'resize')
      @map.map.setCenter(latlng)


  setupMap: ->
    @mapContainer = @container.find('.map')

    @map = { map: null, markers: [] }
    @map.map = new google.maps.Map(@mapContainer.find('.map-container')[0], {
      zoom: 16,
      mapTypeControl: false,
      streetViewControl: false
      mapTypeId: google.maps.MapTypeId.ROADMAP
    })

    @map.marker = new google.maps.Marker({
      map: @map.map,
      icon: @mapContainer.attr("data-marker")
    })


