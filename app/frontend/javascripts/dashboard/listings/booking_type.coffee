module.exports = class BookingType

  constructor: (el)->
    @container = $(el)
    @tabs = @container.find('[data-toggle="tab"]')
    @bindEvents()

  bindEvents: =>
    @tabs.on 'show.bs.tab', (e) =>
      $("input[data-action][data-action!='#{$(e.target).attr('href')}']").val('false')
      $("input[data-action][data-action='#{$(e.target).attr('href')}']").val('true')
