module.exports = class EditUserController

  constructor: (el) ->
    @container = $(el)
    @bindEvents()

  bindEvents: ->
    @container.on 'click', '.provider-not-disconnectable', (event) =>
        $('#user_password').effect("highlight", {}, 3000).focus()
        $('#fill-password-request').removeClass('hidden')
        false
