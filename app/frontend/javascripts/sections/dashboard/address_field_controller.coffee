AddressField = require('../../components/address_autocomplete')
SmartGoogleMap = require('../../components/smart_google_map')

module.exports = class AddressFieldController

  constructor: (@container) ->
    @setupMap()
    @address = new AddressField(@container.find('[data-behavior=address-autocomplete]'))
    @disableEnterFor(@container.find('[data-behavior=address-autocomplete]'))

    @address.onLocate (lat, lng) =>
      latlng = new google.maps.LatLng(lat, lng)

      @map.marker.setPosition(latlng)
      @mapContainer.show()
      google.maps.event.trigger(@map.map, 'resize')
      @map.map.setCenter(latlng)
    @address.bump()

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
    google.maps.event.addListener @map.marker, 'dragend', =>
      position = @map.marker.getPosition()
      @address.markerMoved(position.lat(), position.lng())

  disableEnterFor: (field) ->
    $(field).keydown (event) ->
      if event.keyCode is 13
        event.preventDefault()
        false

