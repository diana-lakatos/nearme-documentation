asEvented = require('asEvented')

module.exports = class SearchRedoSearchMapControl
  asEvented.call @prototype

  template: (update_text) -> "
    <div>
      <label>
        <input type='checkbox' />
        #{update_text}
      </label>
    </div>
  "

  constructor: (options = {}) ->
    @controlDiv = $('<div/>')
    @controlDiv.addClass('search-map-redo-search-control')
    @controlDiv.html(@template(options.update_text))
    @input = @controlDiv.find('input')
    @input.prop('checked', !!options.enabled)
    @bindEvents()

  bindEvents: ->
    @input.on 'change', =>
      @trigger 'stateChanged', @isEnabled()

  isEnabled: ->
    @input.is(':checked')

  isDisabled: ->
    !@isEnabled()

  setMap: (googleMap) ->
    googleMap.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(@getContainer())

  getContainer: ->
    @controlDiv[0]
