class @NavigationBar

  constructor: (@options) ->
    @container = $('#header_links')
    @menuTrigger = @container.find('li.menu-trigger a')
    @menuDivider = @container.find('.menu-divider')
    @bindEvents()

  bindEvents: () ->
    @menuTrigger.bind 'click', () =>
      @container.find('ul.main-menu').toggleClass('open')
      @menuDivider.toggleClass('hidden')
      false


  @initialize: (scope = $('body')) ->
    new NavigationBar(@)
