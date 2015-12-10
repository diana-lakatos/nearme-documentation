module.exports = class InstanceAdminSettingsController

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

    settings_container = $('form.instance_settings')
    settings_container.find('input#instance_password_protected').on 'change', ->
      if !$(this).is(':checked')
        settings_container.find('input#instance_marketplace_password').val('')
