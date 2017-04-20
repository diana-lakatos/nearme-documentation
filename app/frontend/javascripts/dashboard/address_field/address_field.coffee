Geocoder = require('../search/geocoder')
AddressComponentParser = require('./address_component_parser')

# Wrapper for the address and geolocation fields.
#
# Provides an autocomplete on the address field, and sets the location geolocation
# fields (lat, long, address, etc.) on the form.
module.exports = class AddressField

  constructor: (@input) ->
    @inputWrapper = @input.closest('[data-address-field]')
    @autocomplete = new google.maps.places.Autocomplete(@input[0], @getAutocompleteOptions())
    @addressComponentParser = new AddressComponentParser(@inputWrapper)
    @inputChanged = false

    google.maps.event.addListener @autocomplete, 'place_changed', =>
      place = Geocoder.wrapResult @autocomplete.getPlace()
      place = null unless place.isValid()
      if place
        @pickSuggestion(place)

    @input.focus =>
      @picked_result = false
      @inputChanged = false

    @input.change =>
      @inputChanged = true

    @input.blur =>
      geocoder = new Geocoder()
      setTimeout( =>
        # If the blur ocurred without the selection of a result and the input changed then we want to
        # autocomplete to the first item in the autocomplete list if present and if the autocomplete
        # list is not present we set the map to the default place
        if !@picked_result && @inputChanged
          if $('.pac-container').find('.pac-item').length > 0 && @input.val() != ''
            geocoder = new Geocoder()
            first_item = $('.pac-container').find('.pac-item').eq(0)
            query = "#{first_item.find('.pac-item-query').eq(0).text()}, #{first_item.find('> span').eq(-1).text()}"
            deferred = geocoder.geocodeAddress(query)
            deferred.done (resultset) =>
              result = Geocoder.wrapResult resultset.getBestResult().result
              @input.val(query)
              @pickSuggestion(result)
          else
            @setLatLng(null, null)
            @inputWrapper.find("[data-formatted-address]").val(null)
            @inputWrapper.find("[data-local-geocoding]").val("1")
            @input.parent().find('.address_components_input').remove()
            @_onLocate(null, null) if @_onLocate
      , 200)

  getAutocompleteOptions: () =>
    {
      componentRestrictions: {
        country: @input.data('restrict-country') || ''
      }
    }

  markerMoved: (lat, lng) =>
    setTimeout( =>
      geocoder = new Geocoder()
      deferred = geocoder.reverseGeocodeLatLng(lat, lng)
      deferred.done (resultset) =>
        result = Geocoder.wrapResult resultset.getBestResult().result
        @input.val(result.formattedAddress())
        @pickSuggestion(result)
    , 200)

  bump: ->
    if @inputWrapper.find("[data-latitude]").val() && @inputWrapper.find("[data-longitude]").val()
      @setLatLngWithCallback(@inputWrapper.find("[data-latitude]").val(), @inputWrapper.find("[data-longitude]").val())

  onLocate: (callback) ->
    @_onLocate = callback

  pickSuggestion: (place) ->
    @picked_result = true
    @setLatLng(place.lat(), place.lng())
    @inputWrapper.find("[data-formatted-address]").val(place.formattedAddress())
    @inputWrapper.find("[data-local-geocoding]").val("1")
    @addressComponentParser.buildAddressComponentsInputs(place)

    @_onLocate(place.lat(), place.lng()) if @_onLocate

  # Used by map controllers to update the lat-lng by moving map marker.
  setLatLng: (lat, lng) ->
    @inputWrapper.find("[data-latitude]").val(lat)
    @inputWrapper.find("[data-longitude]").val(lng)

  setLatLngWithCallback: (lat, lng) ->
    @setLatLng(lat, lng)
    @_onLocate(lat, lng) if @_onLocate

