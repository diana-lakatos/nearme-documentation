# Class that constrains the height of an element based on the height of another element.
# Useful for preserving equal height of adjacent fluid elements.
#
# Usage:
#   constrainer = new HeightConstrainer(targetElement, contextElement,
#     ratio: height/width
#   )
#   constrainer.on 'constrained', =>
#     # logic required to run on height changed
class @HeightConstrainer
  asEvented.apply @prototype

  defaultOptions:
    # Only adjust every x milliseconds - for performance reasons, particularly if there are callbacks
    throttle: 25

    # (Optional) Ratio for calculating height from width (height = width * ratio), instead of context height
    # eg. If context height is an image, we can't always guarantee it loads. So we provide its known aspect ratio if possible
    ratio: null

  # targetElement - the element which we're manipulating the height of
  # contextElement - the element which we're basing the height from
  constructor: (targetElement, contextElement, options = {}) ->
    @options = $.extend({}, @defaultOptions, options)
    @targetElement = $(targetElement)
    @contextElement = $(contextElement)
    @bindWindowWatcher()
    @constrain()

  bindWindowWatcher: ->
    $(window).resize _.throttle(
      => @constrain(),
      @options.throttle
    )

  constrain: ->
    if $(@targetElement).is(':visible')
      height = if @options.ratio
        Math.round(@contextElement.width() * @options.ratio)
      else
        @contextElement.height()

      @targetElement.height height
      @trigger 'constrained'
