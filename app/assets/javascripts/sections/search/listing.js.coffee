class Search.Listing

  constructor: (element) ->
    @_element = $(element) 
    @_id  = parseInt(@_element.attr('data-id'), 10)
    @_lat = parseFloat(@_element.attr('data-latitude'))
    @_lng = parseFloat(@_element.attr('data-longitude'))
    @_name = @_element.attr('data-name')

  element: -> @_element
  id: -> @_id
  lat: -> @_lat
  lng: -> @_lng
  name: -> @_name

  latLng: ->
    @_latLng ||= new google.maps.LatLng(@_lat, @_lng) 

  popupContent: ->
    @_element.find('.listing-info').html() 

  hide: ->
    @_element.hide()
