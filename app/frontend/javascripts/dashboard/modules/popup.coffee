module.exports = class Popup
  constructor: (link) ->
    @link = $(link)
    @url = @link.attr('href')
    @height = @link.data('popup').height || 440
    @width = @link.data('popup').width || 600
    @bindEvents()

  bindEvents: ->
    @link.on 'click', @openPopup

  openPopup: =>
    newWindow = window.open @url, 'popup', "height=#{@height},width=#{@width}"
    newWindow.focus() if window.focus
    false

