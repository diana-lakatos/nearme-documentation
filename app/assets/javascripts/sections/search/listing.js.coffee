# A simple wrapper around the search result data
#
# TODO: At some point we should probalby be retrieving JSON result data rather than
#       HTML elements.
class Search.Listing
  asEvented.call(Listing.prototype)

  @forElement: (el) ->
    el = $(el)
    listing = el.data("mapListing")
    listing ||= new Search.Listing(el)
    el.data("mapListing", listing)
    listing

  constructor: (element) ->
    @_element = $(element)
    @_id  = parseInt(@_element.attr('data-id'), 10)
    @_lat = parseFloat(@_element.attr('data-latitude'))
    @_lng = parseFloat(@_element.attr('data-longitude'))
    @_name = @_element.attr('data-name')
    @bindEvents()

  # The current implementation of the search results use server-side generated html elements.
  # Since these can change, we want to swap the element we're bound to but still refer to the
  # same client-side Listing object to simplify our event binding and behaviour
  setElement: (element) ->
    if @_element[0] != $(element)[0]
      @_element = $(element)
      @bindEvents()

  bindEvents: ->
    @_element.on 'mouseover', =>
      @focus()
      @trigger 'mouseoverElement'

    @_element.on 'mouseout', =>
      @blur()
      @trigger 'mouseoutElement'

  element: ->
    @_element

  focus: ->
    @_element.addClass('focussed')

  blur: ->
    @_element.removeClass('focussed')

  shouldBlur: ->
    !@popoverOpen

  id: ->
    @_id

  lat: ->
    @_lat

  lng: ->
    @_lng

  name: ->
    @_name

  latLng: ->
    @_latLng ||= new google.maps.LatLng(@_lat, @_lng)

  popoverOpened: ->
    @popoverOpen = true

  popoverClosed: ->
    @popoverOpen = false

  # The content that goes in the map popup when clicking the marker
  popupContent: ->
    @_element.find('.listing-map-popover-content').html()

  # Don't show this result.
  hide: ->
    @_element.hide().addClass('hidden')
