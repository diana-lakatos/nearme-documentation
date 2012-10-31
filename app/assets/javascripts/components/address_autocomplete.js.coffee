class @AddressAutocomplete

  constructor: (@input) ->
    @bindEvents()

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
          .attr("data-lng", loc.lng())
        li = $("<li></li>").append(link)
        ul.append(li)

      el = div.append(message).append(ul)
    else
      el = $("<div></div>").attr("id", "address-suggestions").html("No matches found. Please try another location.")

    @input.after(el)

  hideMatches: ->
    $('#address-suggestions').remove()

  findMatches: ->
    geocoder = new google.maps.Geocoder()

    geocoder.geocode { address: @input.val() }, (results, status) =>
      @showMatches(results)

  bindEvents: ->
    $("#address-suggestions li a").live "click", (event) =>
      event.preventDefault()
      @pickSuggestion($(event.target))
      false

    @input.on 'keypress', (event) =>
      clearTimeout(@_findMatchesTimeout)
      @_findMatchesTimeout = setTimeout =>
        @findMatches()
      , 1500

  pickSuggestion: (selection) ->
    $("#location_latitude").val(selection.attr("data-lat"))
    $("#location_longitude").val(selection.attr("data-lng"))
    $("#location_formatted_address").val(selection.html())
    $("#location_address").val(selection.html())
    $("#address-suggestions").remove()
    $("#location_address").focus()
