# Wrapper for the address and geolocation fields.
#
# Provides an autocomplete on the address field, and sets the location geolocation
# fields (lat, long, address, etc.) on the form.
class @AddressField

  constructor: (@input) ->
    @form = @input.closest('form')
    @autocomplete = new google.maps.places.Autocomplete(@input[0], {})

    google.maps.event.addListener @autocomplete, 'place_changed', =>
      place = Search.Geocoder.wrapResult @autocomplete.getPlace()
      place = null unless place.isValid()
      @pickSuggestion(place) if place

  onLocate: (callback) ->
    @_onLocate = callback

  pickSuggestion: (place) ->
    @setLatLng(place.lat(), place.lng())
    @form.find("#location_formatted_address").val(place.formattedAddress())
    @form.find("#location_address").val(place.cityAddress())
    @form.find("#location_local_geocoding").val("1")

    @_onLocate(place.lat(), place.lng()) if @_onLocate

  # Used by map controllers to update the lat-lng by moving map marker.
  setLatLng: (lat, lng) ->
    @form.find("#location_latitude").val(lat)
    @form.find("#location_longitude").val(lng)
