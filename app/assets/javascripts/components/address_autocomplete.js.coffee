# Wrapper for the address and geolocation fields.
#
# Provides an autocomplete on the address field, and sets the location geolocation
# fields (lat, long, address, etc.) on the form.
class @AddressField

  constructor: (@input) ->
    @form = @input.closest('form')
    @autocomplete = new google.maps.places.Autocomplete(@input[0], {})
    @addressComponentParser = new AddressComponentParser(@form)

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
        if !@picked_result && $('.pac-container').find('.pac-item').length > 0 && @input.val() != ''
          geocoder = new Search.Geocoder()
          first_item = $('.pac-container').find('.pac-item').eq(0)
          query = "#{first_item.find('.pac-item-query').eq(0).text()}, #{first_item.find('> span').eq(-1).text()}"
          deferred = geocoder.geocodeAddress(query)
          deferred.done (resultset) =>
            result = Search.Geocoder.wrapResult resultset.getBestResult().result
            @input.val(query)
            @pickSuggestion(result)
      , 200)
          

  onLocate: (callback) ->
    @_onLocate = callback

  pickSuggestion: (place) ->
    @picked_result = true
    @setLatLng(place.lat(), place.lng())
    @form.find("#location_formatted_address").val(place.formattedAddress())
    @form.find("#location_local_geocoding").val("1")
    @addressComponentParser.buildAddressComponentsInputs(place)

    @_onLocate(place.lat(), place.lng()) if @_onLocate

  # Used by map controllers to update the lat-lng by moving map marker.
  setLatLng: (lat, lng) ->
    @form.find("#location_latitude").val(lat)
    @form.find("#location_longitude").val(lng)

class @AddressComponentParser

  constructor: (@form) ->
    @input_name_prefix = @form.find('#address_component_input').attr('name')
    @addressComponentWrapper = @form.find('#address-component-wrapper')

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
    @form.find('.address_components_input').each ->
      $(this).remove()
