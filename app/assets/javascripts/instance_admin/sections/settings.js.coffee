class @InstanceAdmin.SettingsController

  constructor: (@container, @options = {}) ->
    @bindEvents()

  bindEvents: ->
    @container.on "hidden", ->
      $(this).removeData "modal"
      $(this).find('.modal-body').html( "<p>Loading...</p>" )

    $('table.translations input[type=text]').on 'change', ->
      if $(this).val() == ''
        $(this).next().val('true')
      else
        $(this).next().val('false')
