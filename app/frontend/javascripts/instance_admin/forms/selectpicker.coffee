require '../../vendor/bootstrap-select'

module.exports = class SelectpickerInitializer
  constructor: ->
    @initialize()

  initialize: ->
    $('.selectpicker').selectpicker()
