class @SmartGoogleMap

  @createMap: (@container, @options) =>

    map = new google.maps.Map @container, @options
    @setDraggable(false, map)
    @bindEvents(map)
    map

  @bindEvents: (map) ->
    google.maps.event.addListener map, 'click', =>
       @setDraggable(true, map)

     $(document).mouseup (e) =>
       container = $(map.getDiv())
       if container.has(e.target).length == 0
        @setDraggable(false, map)
    

  @setDraggable: (draggable, map) ->
      if draggable
        $(map.getDiv()).parent().addClass('map-active')
      else
        $(map.getDiv()).parent().removeClass('map-active')
      options = {
          draggable: draggable,
          scrollwheel: draggable
      }
      map.setOptions(options)

