class @InstanceAdmin.SearchSettingsController

  constructor: (@container) ->
    @bindEvents()

  bindEvents: =>
    # handle radius