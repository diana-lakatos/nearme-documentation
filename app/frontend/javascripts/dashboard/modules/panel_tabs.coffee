module.exports = class PanelTabs
  constructor: (el) ->
    @container = $(el)
    @nav = @container.find('ul.tabs')
    @triggers = @nav.find('li')
    @tabs = $('.panel-tab-container')

    @bindEvents()
    @activate(@getInitialIndex())

  bindEvents: ->
    @nav.on 'click', 'a', (e) =>
      index = $(e.target).closest('li').index()
      @activate(index)

  activate: (index) ->
    @triggers.removeClass('active').eq(index).addClass('active')
    @tabs.removeClass('active').eq(index).addClass('active')

  getInitialIndex: ->
    index = @nav.find("li:has(a[href='#{window.location.hash}'])").index()
    if index < 0 then 0 else index
