module.exports = class SmartGoogleMap

  @createMap: (@container, @googleMapOptions, @configuration = undefined) =>

    map = new google.maps.Map @container, @googleMapOptions
    unless @shouldBeIgnored('draggable')
      @setDraggable(false, map)
      @bindEvents(map)
    unless @shouldBeIgnored('styles')
      @setStyles(map)
    map

  @bindEvents: (map) ->
    google.maps.event.addListener map, 'click', =>
      @setDraggable(true, map)

    $(document).mouseup (e) =>
      container = $(map.getDiv())
      if container.has(e.target).length == 0
        @setDraggable(false, map)

  @shouldBeIgnored: (feature) =>
    (@configuration && @configuration.exclude && (feature in @configuration.exclude))

  @setStyles: (map) ->
    options = {
      # JSON generated using: http://gmaps-samples-v3.googlecode.com/svn/trunk/styledmaps/wizard/index.html
      styles: [{"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#457cbc"}]},{"featureType":"water","elementType":"labels.text.stroke","stylers":[{"weight":0.1},
        {"color":"#d0bfe0"},{"visibility":"off"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"visibility":"on"},{"lightness":5},{"color":"#e6e4e7"}]},
        {"featureType":"poi.business","elementType":"labels","stylers":[{"visibility":"simplified"}]},
        {"featureType":"road.arterial","elementType":"geometry.fill","stylers":[{"visibility":"on"},{"color":"#f6edbc"}]},
        {"featureType":"road.arterial","elementType":"labels.text.stroke","stylers":[{"visibility":"off"}]},
        {"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"visibility":"off"}]},{"elementType":"labels.text.stroke","stylers":[{"visibility":"off"}]},
        {"featureType":"poi.school","elementType":"labels","stylers":[{"weight":0.1},{"visibility":"simplified"}]},
        {"featureType":"poi.medical","elementType":"labels","stylers":[{"visibility":"simplified"}]},
        {"featureType":"poi","elementType":"geometry.fill"},{"featureType":"poi.business","stylers":[{"visibility": "off"}]}]
    }
    map.setOptions(options)

  @setDraggable: (draggable, map) ->
    if draggable
      $(map.getDiv()).parent().addClass('map-active')
    else
      $(map.getDiv()).parent().removeClass('map-active')
    options = {
      draggable: draggable,
      scrollwheel: draggable,
    }
    map.setOptions(options)

