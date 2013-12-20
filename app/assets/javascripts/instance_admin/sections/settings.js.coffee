class @InstanceAdmin.SettingsController

  constructor: (@container, @options = {}) ->
    @bindEvents()

  bindEvents: ->
    @container.on "hidden", ->
      $(this).removeData "modal"
