class @SearchResultsGoogleMapMarker
  @displayPngMarker: ->
    if $.browser.msie
      parseInt($.browser.version.substring(0, 4)) <= 8
    else
      # try to detect IE11
      !!navigator.userAgent.match(/Trident.*rv.*11./)

  @markerOptions:
    hover:
      image: new google.maps.MarkerImage(
        '/assets/sections/search/marker-hover.svg',
        new google.maps.Size(40,57),
        new google.maps.Point(0,0),
        new google.maps.Point(10,29),
        new google.maps.Size(20,29)
      )

    default:
      image: new google.maps.MarkerImage(
        '/assets/sections/search/marker-default.svg',
        new google.maps.Size(40,57),
        new google.maps.Point(0,0),
        new google.maps.Point(10,29),
        new google.maps.Size(20,29)
      )

  @markerPngOptions:
    hover:
      image: new google.maps.MarkerImage(
        '/assets/sections/search/marker-hover.png',
        new google.maps.Size(40,57),
        new google.maps.Point(0,0),
        new google.maps.Point(10,29),
        new google.maps.Size(20,29)
      )

    default:
      image: new google.maps.MarkerImage(
        '/assets/sections/search/marker-default.png',
        new google.maps.Size(40,57),
        new google.maps.Point(0,0),
        new google.maps.Point(10,29),
        new google.maps.Size(20,29)
      )

  @getMarkerOptions: ->
    if @displayPngMarker()
      @markerPngOptions
    else
      @markerOptions
