class @InstanceAdmin.SettingsController

  constructor: (@container, @options = {}) ->
    @bindEvents()

  bindEvents: ->
    @container.on "hidden", ->
      $(this).removeData "modal"
      $(this).find('.modal-body').html( "<p>Loading...</p>" );
