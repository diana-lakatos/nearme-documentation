# Base class for positioned view modal containers generated client-side
#
# Used for the Datepicker and TimePicker modals.
module.exports = class PositionedView

  containerTemplate: """
    <div></div>
  """

  defaultOptions__PositionedView:
    positionTarget: null
    containerClass: null
    windowRightPadding: 20
    positionPadding: 5

  constructor: (@options) ->
    @options = $.extend({}, @defaultOptions__PositionedView, @options)

    @container = $(@containerTemplate).hide()
    @container.addClass(@options.containerClass) if @options.containerClass
    @positionTarget = $(@options.positionTarget)

    @container.on 'click', (event) -> event.stopPropagation()

  closeIfClickedOutside: (clickTarget) ->
    clickTarget = $(clickTarget)

    $('body').on 'click', (event) =>
      if clickTarget[0] != event.target && clickTarget.has(event.target).length == 0
        @hide()

  # Render the the view by appending it to a container
  appendTo: (selector) ->
    $(selector).append(@container)

  toggle: ->
    if @isVisible()
      @hide()
    else
      @show()

  show: ->
    # Reset rendering position
    @renderPosition = null

    @container.show()
    @reposition()

  hide: ->
    @container.hide()

  isVisible: ->
    @container.is(':visible')

  reposition: ->
    return unless @positionTarget.length > 0

    # Width/height of the datepicker container
    width = @container.width()
    height = @container.height()

    # Offset of the position target reletave to the page
    tOffset = @positionTarget.offset()

    # Width/height of the position target
    tWidth = @positionTarget.outerWidth()
    tHeight = @positionTarget.outerHeight()

    # Window height and scroll position
    wHeight = $(window).height()
    wWidth  = $(window).width()
    sTop    = $(window).scrollTop()

    # Calculate available viewport height above/below the target
    heightAbove = tOffset.top - sTop
    heightBelow = wHeight + sTop - tOffset.top

    # Determine whether to place the datepicker above or below the target element.
    # If there is enough window height above element to render the container, then we put it
    # above. If there is not enough (i.e. it would be partially hidden if rendered above), then
    # we render it below the target.
    if @renderPosition != 'below' && (@renderPosition == 'above' || heightAbove < height)
      top = tOffset.top + tHeight + @options.positionPadding
      @renderPosition = 'above'
    else
      # Render above element
      top = tOffset.top - height - @options.positionPadding
      @renderPosition = 'below'

    # Left position is based off the container width and the position target width/position
    left = tOffset.left + parseInt(tWidth/2, 10) - parseInt(width/2, 10)

    # Don't let it render outside of the window viewport on the right side.
    # Also force minimum padding, and shift the position left until it fits properly.
    rightPos = left + width
    if rightPos > (wWidth - @options.windowRightPadding)
      left -= (rightPos - wWidth + @options.windowRightPadding)

    # Update the position of the datepicker container
    @container.css(
      'top': "#{top}px",
      'left': "#{left}px"
    )

