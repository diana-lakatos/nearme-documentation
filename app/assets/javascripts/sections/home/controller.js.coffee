class Home.Controller

  constructor: (@container) ->
    @callToAction = @container.find('a[data-call-to-action]')
    @howItWorks = @container.find('section.how-it-works')
    @homepageContentTopOffset = 20
    @bindEvents()


  bindEvents: =>
    @callToAction.on 'click', (e) =>
      content_top = @howItWorks.offset().top - @homepageContentTopOffset
      $('html, body').animate
        scrollTop: content_top
        900
      false
