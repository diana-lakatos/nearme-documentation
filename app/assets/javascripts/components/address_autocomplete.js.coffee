class @AddressAutocomplete

  constructor: (@input) ->
    @autocomplete = new google.maps.places.Autocomplete(@input[0], {})
    google.maps.event.addListener @autocomplete, 'place_changed', =>
      place = Search.Geocoder.wrapResult @autocomplete.getPlace()
      place = null unless place.isValid()
      @pickSuggestion(place) if place

  onLocate: (callback) ->
    @_onLocate = callback

  pickSuggestion: (place) ->
    $("#location_latitude").val(place.lat())
    $("#location_longitude").val(place.lng())
    $("#location_formatted_address").val(place.formattedAddress())
    $("#location_address").val(place.cityAddress())
    $("#location_local_geocoding").val("1")

    @_onLocate(place.lat(), place.lng()) if @_onLocate
