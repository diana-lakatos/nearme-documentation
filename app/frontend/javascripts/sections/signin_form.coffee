ModalForm = require('../components/modal_form')

module.exports = class SigninForm extends ModalForm

  constructor: (@container) ->
    @form = @container.find('#new_user')
    super @container, @form

  bindEvents: ->
    super
