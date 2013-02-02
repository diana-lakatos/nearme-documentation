class DNM.UI.GeoFinder
  constructor: (anchor, geoPosition) ->
    @anchor = anchor
    @autocomplete = new google.maps.places.Autocomplete(@anchor[0], {})
    google.maps.event.addListener @autocomplete, 'place_changed', =>
      place = DNM.Geocoder.wrapResult @autocomplete.getPlace()
      place = null unless place.isValid()
      geoPosition.setPosition({latitude: place.lat(), longitude: place.lng()})
