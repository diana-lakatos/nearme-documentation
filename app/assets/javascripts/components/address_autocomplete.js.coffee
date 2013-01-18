class @AddressComponentParser

  component_separator = "+"
  part_separator = "|"
  key_value_separator = ":"
  type_separator = ","


  buildAddressComponentsString: (result) ->
    #it will require some parsing 
    #component =  components.split("+") 
    #parts = component.split("|") -> parts[0] = long_name, parts[1] = short_name, parts[2] = types
    #types = parts[2].split(",") 
    address_component_string = ""
    for address_component in result['address_components']
      address_component_string += @add_names(address_component)
      address_component_string += @add_types(address_component)
      address_component_string += component_separator
    address_component_string.slice(0, -1)

  add_names: (address_component) ->
    "long_name" + key_value_separator + address_component['long_name'] + part_separator +
    "short_name" + key_value_separator + address_component['short_name']

  add_types: (address_component) ->
    if !!address_component['types']
      part_separator + "types" + key_value_separator + address_component['types'].join(type_separator)

  buildAddressComponentsForm: (addressComponentsString) ->
    alert('invoked')

    


class @AddressAutocomplete

  constructor: (@input) ->
    @addressComponentParser = new AddressComponentParser
    @bindEvents()
    @setupInput()

  onLocate: (callback) ->
    @_onLocate = callback

  # Show autocomplete matches with the results array
  showMatches: (results) ->
    @hideMatches()
    if results.length > 0
      div = $("<div></div>").attr("id", "address-suggestions")
      ul = $("<ul></ul>")
      message = $("<p>Please select which location best matches where the location is</p>")

      for result in results
        loc = result['geometry']['location']
        link = $("<a href='#'></a>")
          .html(result['formatted_address'])
          .attr("data-lat", loc.lat())
          .attr("data-address-components", @addressComponentParser.buildAddressComponentsString(result))
          .attr("data-lng", loc.lng())
          .data("result", loc)
        li = $("<li></li>").append(link)
        ul.append(li)

      el = div.append(message).append(ul)
    else
      el = $("<div></div>").attr("id", "address-suggestions").html("No matches found. Please try another location.")

    @inputWrapper.after(el)



  hideMatches: ->
    $('#address-suggestions').remove()

  findMatches: ->
    geocoder = new google.maps.Geocoder()

    geocoder.geocode { address: @input.val() }, (results, status) =>
      @hideLoading()
      @showMatches(results)

  bindEvents: ->
    $("#address-suggestions li a").live "click", (event) =>
      event.preventDefault()
      @pickSuggestion($(event.target))
      false

    @input.on 'keypress', (event) =>
      @showLoading()
      clearTimeout(@_findMatchesTimeout)
      @_findMatchesTimeout = setTimeout =>
        @findMatches()
      , 1500

  pickSuggestion: (selection) ->
    @setLatLng(selection.attr("data-lat"), selection.attr("data-lng"))
    $("#location_formatted_address").val(selection.html())
    $("#location_address").val(selection.html())
    $("#address-suggestions").remove()
    $("#location_address").focus()
    $("#location_local_geocoding").val("1")
    @addressComponentParser.buildAddressComponentsForm(selection.attr("data-address-components"))
    @_onLocate(selection.attr('data-lat'), selection.attr('data-lng')) if @_onLocate

  setLatLng: (lat, lng) ->
    $("#location_latitude").val(lat)
    $("#location_longitude").val(lng)

  showLoading: ->
    @geolocateTrigger.hide()
    @loadingSpinner.show()

  hideLoading: ->
    @loadingSpinner.hide()
    @geolocateTrigger.show()

  setupInput: ->
    # Wrap input element
    @input.wrap('<div class="input-icon-wrapper"/>')
    @inputWrapper = @input.parent()

    # Add icon
    @geolocateTrigger = $('<i class="icon ico-crosshairs geolocate-trigger" />')
    @inputWrapper.append(@geolocateTrigger)

    # Add loading spinner
    @loadingSpinner = $('<i class="icon icon-loading" />')
    @loadingSpinner.hide()
    @inputWrapper.append(@loadingSpinner)

