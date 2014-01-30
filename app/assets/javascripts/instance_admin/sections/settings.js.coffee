class @InstanceAdmin.SettingsController

  constructor: (@container, @options = {}) ->
    @bindEvents()

  bindEvents: ->
    @container.on "hidden", ->
      $(this).removeData "modal"
      $(this).find('.modal-body').html( "<p>Loading...</p>" )

    settings_container = $('form.instance_settings')
    settings_container.find('input#instance_password_protected').on 'change', ->
      if !$(this).is(':checked')
        settings_container.find('input#instance_marketplace_password').val('')
