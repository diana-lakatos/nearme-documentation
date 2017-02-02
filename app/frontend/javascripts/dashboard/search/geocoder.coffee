module.exports = class Geocoder
  class ResultSet
    constructor: (results) ->
      @results = []
      @results.push(new Result(result)) for result in results

    getBestResult: ->
      @results[0]

    getResults: ->
      @results

  class Result
    constructor: (@result) ->

    isValid: ->
      @result && @result.geometry

    postcode: ->
      @_addressComponentOfType('postal_code', 'political')?.long_name

    street: ->
      @_addressComponentOfType('route', 'political')?.long_name

    suburb: ->
      @_addressComponentOfType('sublocality', 'political')?.long_name

    city: ->
      @_addressComponentOfType('locality', 'political')?.long_name

    state: ->
      @_addressComponentOfType('administrative_area_level_1', 'political')?.long_name

    stateShort: ->
      @_addressComponentOfType('administrative_area_level_1', 'political')?.short_name

    country: ->
      @_addressComponentOfType('country', 'political')?.long_name

    cityAddress: ->
      "#{@city()}, #{@country()}" if @city()

    cityAndStateAddress: ->
      loc_components = []
      loc_components.push @city() if @city()
      loc_components.push @stateShort() if @stateShort()
      loc_components.push @country()
      loc_components.join(', ')

    lat: ->
      @result.geometry.location?.lat()

    lng: ->
      @result.geometry.location?.lng()

    boundingBox: ->
      sw = @result.geometry.viewport?.getSouthWest()
      ne = @result.geometry.viewport?.getNorthEast()
      [sw?.lat(), sw?.lng(), ne?.lat(), ne?.lng()]

    formattedAddress: ->
      @result.formatted_address

    _addressComponentOfType: (types...) ->
      component = null
      for c in @result.address_components
        t = c.types
        match = true
        match = (match && _.contains(t, type)) for type in types
        component = c if match
      component

  # Return a wrapped geocoder/places API response result object
  @wrapResult: (resultObject) ->
    new Result(resultObject)

  constructor: ->
    @geocoder = new google.maps.Geocoder()

  # Geocode an address, returning a jQuery Defferred callback object.
  geocodeAddress: (address) ->
    @geocodeWithOptions({ 'address': address })

  # Reverse geocode from latlng coordinates
  reverseGeocodeLatLng: (lat_or_latlng, lng = undefined) ->
    if lat_or_latlng instanceof google.maps.LatLng
      latlng = lat_or_latlng
    else
      latlng = new google.maps.LatLng(lat_or_latlng, lng)

    @geocodeWithOptions({ latLng: latlng })

  geocodeWithOptions: (options) ->
    deferred = jQuery.Deferred()

    @geocoder.geocode options, (results, status) ->
      if status == google.maps.GeocoderStatus.OK
        deferred.resolve new ResultSet(results)
      else
        deferred.reject()

    deferred
