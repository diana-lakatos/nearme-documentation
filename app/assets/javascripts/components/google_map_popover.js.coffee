# Wrapper class for our custom Google Map popover dialog boxes.
class @GoogleMapPopover
  defaultOptions:
    boxClass: 'google-map-popover'
    pixelOffset: null
    maxWidth: 0
    boxStyle:
      width: "288px"
    alignBottom: true
    contentWrapper: """
      <div>
        <div class="google-map-popover-content"></div>
        <em class="arrow-border"></em>
        <em class="arrow"></em>
        <a href="" class="close ico-close"></a>
      </div>
    """

  constructor: (options) ->
    @options = $.extend @getDefaultOptions(), options
    @infoBox = new InfoBox(
      maxWidth: @options.maxWidth
      boxClass: @options.boxClass
      pixelOffset: @options.pixelOffset
      boxStyle: @options.boxStyle
      alignBottom: @options.alignBottom
      content: ""
      closeBoxURL: ""
      infoBoxClearance: new google.maps.Size(1, 1)
    )

  close: ->
    @infoBox.close()

  open: (map, position) ->
    @infoBox.open(map, position)

  setContent: (content) ->
    @infoBox.setContent @wrapContent(content)

  getDefaultOptions: ->
    $.extend {}, @defaultOptions, {
      pixelOffset: new google.maps.Size(-150, -40)
    }

  wrapContent: (content) ->
    wrapper = $(@options.contentWrapper)

    # We need to wrap the close button click to close
    wrapper.find('.close').on 'click', (event) =>
      event.preventDefault()
      @close()

    wrapper.find('.google-map-popover-content').html(content)
    wrapper[0]
