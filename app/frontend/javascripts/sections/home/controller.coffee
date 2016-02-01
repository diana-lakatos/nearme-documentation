module.exports = class HomeController

  constructor: (container) ->
    @container = $(container)
    @callToAction = @container.find('a[data-call-to-action]')
    @howItWorks = $('section.how-it-works')
    @homepageContentTopOffset = 90

    return unless @callToAction.length isnt 0 and @howItWorks.length isnt 0
    @bindEvents()


  bindEvents: =>
    @callToAction.on 'click', (e) =>
      content_top = @howItWorks.offset().top - @homepageContentTopOffset
      $('html, body').animate
        scrollTop: content_top
        900
      false
