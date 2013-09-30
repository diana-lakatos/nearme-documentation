class Search.RedoSearchMapControl
  asEvented.call(RedoSearchMapControl.prototype)

  template: '''
    <div>
      <label>
        <input type="checkbox" />
        Update search when map moved
      </label>
    </div>
  '''

  constructor: (options = {}) ->
    @controlDiv = $('<div/>')
    @controlDiv.addClass('search-map-redo-search-control')
    @controlDiv.html(@template)
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
    googleMap.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(@getContainer());

  getContainer: ->
    @controlDiv[0]
