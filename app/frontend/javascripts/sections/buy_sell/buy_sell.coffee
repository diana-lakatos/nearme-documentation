module.exports = class BuySellController

  constructor: (@container) ->
    @bindEvents()

  bindEvents: =>
    @container.find('input.zone_kind').on 'change', (e) =>
      @container.find('.zone-members-container').addClass('hide')
      @container.find("##{$(e.currentTarget).attr('id')}_container").removeClass('hide')
