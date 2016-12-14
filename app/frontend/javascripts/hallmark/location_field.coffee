module.exports = class LocationField
  constructor: (el)->
    @root = $(el)
    @input = @root.find('input')
    @map = @root.find('.map')

    @init()

    @getCurrentPosition() if !@input.val()

  onFindPositionSuccess: (position)->
    latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)

    input = @input
    geocoder = new google.maps.Geocoder;
    geocoder.geocode {'location': latlng}, (results, status)->
      return unless status == google.maps.GeocoderStatus.OK and results[1]
      input.geocomplete('find', results[1].formatted_address)

  onFindPositionError: (msg)->
    console.log(msg)

  getCurrentPosition: ()->
    return unless navigator.geolocation
    navigator.geolocation.getCurrentPosition @onFindPositionSuccess.bind(this), @onFindPositionError

  init: ()->
    @input.geocomplete(
      map: @map.get(0)
      mapOptions:
        disableDefaultUI: true
        disableDoubleClickZoom: true
        minZoom: 9
        maxZoom: 9
        draggable: false
        panControl: false
    )

    @input.on 'geocode:result', $.proxy((event, result) ->
      @root.addClass 'is-touched'
    ), this

    @input.on 'blur', (event) ->
      $(this).trigger 'geocode'

    @input.trigger('geocode') if @input.val()

  @initialize: ()->
    return unless window.google and window.google.maps

    $('.form-a .location').each ()->
      new LocationField(this)

