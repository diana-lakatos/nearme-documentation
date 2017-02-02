require('../../vendor/jquery.hasScrollBar')
asEvented = require('asevented')
InfoBox = require('exports?InfoBox!../../vendor/infobox')

# Wrapper class for our custom Google Map popover dialog boxes.
module.exports = class GoogleMapPopover
  asEvented.apply @prototype

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
    @trigger 'closed'

  open: (map, position) ->
    @close()
    @infoBox.open(map, position)
    @trigger 'opened'

  setContent: (content) ->
    @infoBox.setContent @wrapContent(content)

  setError: (content) ->
    @infoBox.setContent @wrapContent("<div class='popover-error'><span class=''>#{content}</span></div>")

  markAsBeingLoaded: ->
    @infoBox.setContent @wrapContent('<div class="popover-loading"><img src="' + $('.loading').find('img').attr('src') + '"><br /><span>Loading...</span></div>')

  getDefaultOptions: ->
    $.extend {}, @defaultOptions, {
      pixelOffset: new google.maps.Size(-144, -40)
    }

  wrapContent: (content) ->
    # We need to wrap the close button click to close

    wrapper = $(@options.contentWrapper)
    wrapper.find('.google-map-popover-content').html(content)

    wrapper.find('.listing-sibling').on 'click', (event) ->
      location.href = $(@).attr('data-link')
    wrapper.find('h4.location-title:first-child').append('<a href="" class="close ico-close"></a>')
    wrapper.find('.close').on 'click', (event) =>
      event.preventDefault()
      @close()
    if wrapper.find('.google-map-popover-content').length > 0
      if wrapper.find('.google-map-popover-content').hasScrollBar()
        $(".#{@options.boxClass}").addClass('with-scrollbar')
      else
        $(".#{@options.boxClass}").removeClass('with-scrollbar')
    wrapper[0]
