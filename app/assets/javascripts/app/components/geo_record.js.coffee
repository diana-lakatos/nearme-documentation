class DNM.UI.GeoRecord
  constructor: (store) ->
    @store = store

  update: (geoPosition) ->
    @store.latitude.val(geoPosition.latitude)
    @store.longitude.val(geoPosition.longitude)

  getLatitude: ->
    Number(@store.latitude.val())

  getLongitude: ->
    Number(@store.longitude.val())
