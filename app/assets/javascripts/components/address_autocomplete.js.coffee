# Wrapper for the address and geolocation fields.
#
# Provides an autocomplete on the address field, and sets the location geolocation
# fields (lat, long, address, etc.) on the form.
class @AddressField

  constructor: (@input) ->
    @inputWrapper = @input.closest('[data-address-field]')
    @autocomplete = new google.maps.places.Autocomplete(@input[0], {})
    @addressComponentParser = new AddressComponentParser(@inputWrapper)

    google.maps.event.addListener @autocomplete, 'place_changed', =>
      place = Search.Geocoder.wrapResult @autocomplete.getPlace()
      place = null unless place.isValid()
      if place
        @pickSuggestion(place)

    @input.focus =>
      @picked_result = false

    @input.blur =>
      geocoder = new Search.Geocoder()
      setTimeout( =>
        if !@picked_result
          if $('.pac-container').find('.pac-item').length > 0 && @input.val() != ''
            geocoder = new Search.Geocoder()
            first_item = $('.pac-container').find('.pac-item').eq(0)
            query = "#{first_item.find('.pac-item-query').eq(0).text()}, #{first_item.find('> span').eq(-1).text()}"
            deferred = geocoder.geocodeAddress(query)
            deferred.done (resultset) =>
                  result = Search.Geocoder.wrapResult resultset.getBestResult().result
                  @input.val(query)
                  @pickSuggestion(result)
          else
            @setLatLng(null, null)
            @inputWrapper.find("[data-formatted-address]").val(null)
            @inputWrapper.find("[data-local-geocoding]").val("1")
            @input.parent().find('.address_components_input').remove()
            @_onLocate(null, null) if @_onLocate
      , 200)

  markerMoved: (lat, lng) =>
    setTimeout( =>
      geocoder = new Search.Geocoder()
      deferred = geocoder.reverseGeocodeLatLng(lat, lng)
      deferred.done (resultset) =>
            result = Search.Geocoder.wrapResult resultset.getBestResult().result
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

class @AddressComponentParser

  constructor: (@inputWrapper) ->
    @input_name_prefix = @inputWrapper.find('input[data-address-components-input]').attr('name')
    @addressComponentWrapper = @inputWrapper.find('.address-component-wrapper')

  buildAddressComponentsInputs: (place) =>
    @clearAddressComponentInputs()
    @index = 0
    for addressComponent in place.result.address_components
      @buildInput("#{@input_name_prefix}[#{@index}][long_name]", addressComponent.long_name)
      @buildInput("#{@input_name_prefix}[#{@index}][short_name]", addressComponent.short_name)
      @buildInput("#{@input_name_prefix}[#{@index}][types]", addressComponent.types.toString())
      @index += 1

  buildInput: (name, value) =>
    input = $('<input type="hidden"/>')
    input.attr('name', name).addClass('address_components_input').val(value)
    @addressComponentWrapper.append(input)

  clearAddressComponentInputs: =>
    @inputWrapper.find('.address_components_input').each ->
      $(this).remove()
