require('jquery.cookie/jquery.cookie')

module.exports = class IntroVideo

  constructor: (container) ->
    @loadApi()

    @container = $(container)
    @initStructure()
    @videoWrap = @container.find('.intro-video-wrapper')
    @iframe = @videoWrap.find('iframe')
    @overlay = @container.find('.intro-video-overlay')
    @closeButton = @container.find('.intro-video-close')
    @cookieName = 'hide_intro_video'
    @videoAspectRatio = 1280/720


    @bindEvents()

  loadApi: ->
    tag = document.createElement('script')
    tag.src = "https://www.youtube.com/iframe_api"
    firstScriptTag = document.getElementsByTagName('script')[0]
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)

  initStructure: ->
    @container.html('<div class="intro-video-overlay"></div><div class="intro-video-wrapper"><div id="intro-player"></div></div><button type="button" class="intro-video-close button-a">Close Video</button>')
    @container.addClass('initialised')

    @trigger = $('<button type="button" id="intro-video-toggler">Play Video <span>Again</span></button>')
    @trigger.appendTo('body')

  bindEvents: ->
    @trigger.on 'click', (e) =>
      e.preventDefault()
      e.stopPropagation()

      @showVideo()

    @overlay.add(@closeButton).add(@videoWrap).on 'click.introvideo', (e) =>
      @hideVideo()

    $(window).on 'resize', =>
      @resizePlayer()

    window.onYouTubeIframeAPIReady = =>
      @player = new YT.Player 'intro-player', {
        height: 1280
        width: 720
        videoId: 'cBamideLh3g'
        events:
          onReady: @onPlayerReady
          onStateChange: @onPlayerStateChange
        playerVars:
          rel: 0
          fs: 0
      }

  bindOnShow: ->
    $('body').on 'keydown.introvideo', (e) =>
      if e.which == 27 # Hitting escape
        @hideVideo()


  onPlayerStateChange: (event) =>
    if event.data == YT.PlayerState.ENDED
      @hideVideo()

  onPlayerReady: (event) =>
    return if @container.hasClass 'inactive'

    unless Modernizr.touchevents
      event.target.mute()
      event.target.playVideo()

    @bindOnShow()
    @resizePlayer()

  hideVideo: ->
    @container.addClass('inactive')
    $.cookie(@cookieName, 1, { expires: 28, path: '/' })
    @player.stopVideo() if @player.stopVideo

    $('body').off('*.introvideo')

  resizePlayer: ->
    x = @videoWrap.width() - 40
    y = @videoWrap.height() - 40
    wrapperAspectRatio = x / y

    @iframe = @videoWrap.find('iframe') unless @iframe.length > 0

    return if @iframe.length == 0

    if wrapperAspectRatio > @videoAspectRatio
      x = y * @videoAspectRatio
    else if wrapperAspectRatio < @videoAspectRatio
      y = x / @videoAspectRatio

    x = Math.round(x)
    y = Math.round(y)

    @iframe.css(width: x, height: y)

  showVideo: ->
    @container.removeClass('inactive')
    @resizePlayer()

    unless Modernizr.touchevents
      @player.playVideo() if @player.playVideo
    @bindOnShow()


