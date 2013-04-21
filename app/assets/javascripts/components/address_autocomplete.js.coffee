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
      @pickSuggestion(place) if place

  onLocate: (callback) ->
    @_onLocate = callback

  pickSuggestion: (place) ->
    @setLatLng(place.lat(), place.lng())
    @form.find("#location_formatted_address").val(place.formattedAddress())
    @form.find("#location_address").val(place.cityAddress())
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
    console.log place
    @clearAddressComponentInputs()
    @index = 0
    for addressComponent in place.result.address_components
      @buildInput("#{@input_name_prefix}[#{@index}][long_name]", addressComponent.long_name)
      @buildInput("#{@input_name_prefix}[#{@index}][short_name]", addressComponent.short_name)
      @buildInput("#{@input_name_prefix}[#{@index}][types]", addressComponent.types.toString())
      @index += 1

  buildInput: (name, value) =>
    input = document.createElement('input')
    input.name = name
    input.type = 'hidden'
    input.value = value
    input.className = 'address_components_input'
    @addressComponentWrapper.append(input)

  clearAddressComponentInputs: =>
    @form.find('.address_components_input').each ->
      $(this).remove()
