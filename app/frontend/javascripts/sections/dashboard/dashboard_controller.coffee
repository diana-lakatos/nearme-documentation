module.exports = class DashboardController

  HEADER_SPACE_FROM_ICO_EDIT = 25

  constructor: (@container) ->
    @bindEvents()
    @setMaxWidth()

  bindEvents: =>
    $(window).resize =>
      @setMaxWidth()


  setMaxWidth: =>
    @location = @container.find('li.location').eq(0)
    $('li.location .name').css('maxWidth', (@location.width() - $(@location).find('.links').width()) - 10 + 'px')
    @container.find('li.listing').each (index, element) ->
      $(element).find('.name').css('maxWidth', ($(element).width() - $(element).find('a').width()) - 10 + 'px')
