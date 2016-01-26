require 'bootstrap-select/js/bootstrap-select'

module.exports = class SelectpickerInitializer
  constructor: ()->
    @initialize()

  initialize: ()->
    $('.selectpicker').selectpicker();
