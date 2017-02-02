require('bootstrap-switch/src/coffee/bootstrap-switch')

module.exports = class BootstrapSwitchInitializer
  constructor: (el) ->
    @el = $(el)

    @bindEvents()
    @initialize()

  bindEvents: ->

  initialize: ->
    @el.bootstrapSwitch()
