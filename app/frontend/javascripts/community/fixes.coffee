module.exports = class Fixes
  constructor: ->

  # rewrites <img> src attributes from *.svg to *.png on browsers with lacking support
  @svg: ->
    return unless !Modernizr.svg or document.querySelectorAll('html.android.native').length > 0

    imgs = document.getElementsByTagName('img')
    endsWithDotSvg = /.*\.svg$/
    i = 0
    l = imgs.length
    while i != l
      if imgs[i].src.match(endsWithDotSvg)
        imgs[i].src = imgs[i].src.slice(0, -3) + 'png'
      ++i

  @enhancements: ->
    # Add class .last-child to all relevant elements in older browsers
    if !document.addEventListener
      $('*:last-child').addClass('last-child')


  @initialize: ->
    @svg()
    @enhancements()

