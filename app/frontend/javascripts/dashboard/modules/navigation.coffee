require('jquery.cookie/jquery.cookie')

module.exports = class Navigation
  cookie_name: 'navigation_visible'

  constructor: ->
    @body = $(document.body)
    @main = $('main')

    @createToggler()
    @subnavigationItems()

    setTimeout (->
      $('body').addClass('navigation-toggle-initialized')
    ), 50

  createToggler: ->
    @toggler = $('button.nav-toggler')

    togglerClick = (e) ->
      e.preventDefault()
      e.stopPropagation()
      @toggleNavigation()

    @toggler.on 'click', $.proxy(togglerClick, this)

    $('.page-header-wrapper').prepend(@toggler)


  saveState: (state) ->
    $.cookie(@cookie_name, state, { expires: 14, path: '/dashboard/' })

  readState: ->
    return $.cookie(@cookie_name)

  showNavigation: ->
    @body.addClass('navigation-visible')
    @saveState(true)

    @main.on 'click.hidenavigation', (e) =>
      e.preventDefault()
      @hideNavigation()

  hideNavigation: ->
    @body.removeClass('navigation-visible')
    @saveState(false)
    @main.off('click.hidenavigation')

  toggleNavigation: ->
    return @hideNavigation() if @body.hasClass('navigation-visible')
    @showNavigation()

  subnavigationItems: ->
    $('.nav-primary').on 'click', 'li > span', (e) ->
      $(e.target).closest('li').toggleClass('selected')
