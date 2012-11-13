# A simple modal implementation
#
# FIXME: Requires pre-existing HTML markup
# TODO: This is just a first-cut. We can tidy this up and allow further customisation etc.
#
# Usage:
#   # Load a URL and have Modal handle all the loading view and content showing, etc:
#   Modal.load("/my/url")
#
#   # Manually trigger the loading view of a visible modal:
#   Modal.showLoading()
#
#   # Manually update the content of a visible modal:
#   Modal.showContent("my new content")
class @Modal

  # Listen for click events on modalized links
  # Modalized links are anchor elements with rel="modal"
  # A custom class can be specified on the modal:
  #   <a href="modalurl" rel="modal.my-class">link</a>
  @listen : ->
    $('body').delegate 'a[rel*="modal"]', 'click', (e) =>
      e.preventDefault()
      target = $(e.currentTarget)
      modalClass = matches[1] if matches = target.attr("rel").match(/modal\.([^\s]+)/)

      @load(target.attr("href"), modalClass)
      false

  # Show the loading status on the modal
  @showLoading : ->
    @instance().showLoading()

  # Show the content on the modal
  @showContent : (content) ->
    @instance().showContent(content)

  # Trigger laoding of the URL within the modal via AJAX
  @load : (url, modalClass = null) ->
    @instance().setClass(modalClass)
    @instance().load(url)

  # ===

  constructor: (@options) ->
    @container = $('.modal-container')
    @content = @container.find('.modal-content')
    @loading = @container.find('.modal-loading')
    @bodyContainer = $('.dnm-page')
    @overlay = $('.modal-overlay')

    # Bind to any element with "close" class to trigger close on the modal
    @container.delegate ".close", 'click', (e) =>
      e.preventDefault()
      @hide()

    # Bind to the overlay to close the modal
    @overlay.bind 'click', (e) =>
      @hide()

  setClass : (klass) ->
    @container.attr("class", 'modal-container') # FIXME: Make the modal markup dynamic and customizable default class(es)
    @container.addClass(klass) if klass

  showContent : (content) ->
    @_show()
    @loading.hide()
    @content.html("") if content
    @content.show()
    @content.html(content) if content

  showLoading : ->
    @content.hide()
    @loading.show()

  hide: ->
    @_unfixBody()
    @overlay.hide()
    @container.hide()

  # Trigger visibility of the modal
  _show: ->
    @_fixBody()
    @overlay.show()
    @container.show()
    @positionModal()

  # Load the given URL in the modal
  # Displays the modal, shows the loading status, fires an AJAX request and 
  # displays the content
  load : (url) ->
    @_show()
    @showLoading()

    $.get url, (data) =>
      @showContent(data)

  # Position the modal on the page.
  positionModal: ->
    height = @container.height()
    windowHeight = $(window).height()
    width = @container.width()

    # FIXME: Pass these in as configuration options to the modal
    @container.css(position: 'absolute', top: '50px', left: '50%', 'margin-left': "-#{parseInt(width/2)}px")

  # Fix the position of the main page content, preventing scrolling and allowing the window scrollbar to scroll the modal's content instead.
  _fixBody: ->
    scrollTop = $(window).scrollTop()
    @_scrollTopWas = scrollTop
    @bodyContainer.wrap("<div id='modal-body-wrapper'/>").parent().css(width: '100%', position: "fixed", 'margin-top': "-#{scrollTop}px")
    $(window).scrollTop(0)

  # Reverse the 'fixing' of the primary page content
  _unfixBody: ->
    # FIXME: if this is called in error...
    @bodyContainer.unwrap()
    $(window).scrollTop(@_scrollTopWas)

  # Get the instance of the Modal object
  @instance : ->
    window.modal ||= new Modal()

