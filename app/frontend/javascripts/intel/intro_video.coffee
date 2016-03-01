require('jquery.cookie/jquery.cookie')

module.exports = class IntroVideo

  constructor: (container)->
    @loadApi()

    @container = $(container)
    @videoWrap = @container.find('.intro-video-wrap')
    @cookieName = 'hide_intro_video'

    @initStructure()
    @bindEvents()

  loadApi: ->
    tag = document.createElement('script')
    tag.src = "https://www.youtube.com/iframe_api";
    firstScriptTag = document.getElementsByTagName('script')[0]
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)

  initStructure: ->
    @trigger = $('<button type="button" id="intro-video-toggler">Play Video <span>Again</span></button>')
    @trigger.appendTo('body')

  bindEvents: ->
    @trigger.on 'click', (e)=>
      e.preventDefault()
      e.stopPropagation()

      @showVideo()

    window.onYouTubeIframeAPIReady = =>
      @player = new YT.Player 'intro-player', {
        height: 1280
        width: 720
        videoId: 'W3d4gNLUJzE'
        events:
          onReady: @onPlayerReady
          onStateChange: @onPlayerStateChange
        playerVars:
          controls: 0
          rel: 0
      }

  bindOnShow: ->
    $('body').on 'click.introvideo', (e)=>
      if $(e.target).closest('.intro-video-wrap').length == 0
        e.preventDefault()
        e.stopPropagation()
        @hideVideo()

    $('body').on 'keydown.introvideo', (e)=>
      if e.which == 27 # Hitting escape
        @hideVideo()


  onPlayerStateChange: (event)=>
    if event.data == YT.PlayerState.ENDED
      @hideVideo()

  onPlayerReady: (event) =>
    return if @container.hasClass 'inactive'

    event.target.playVideo()
    @bindOnShow()

  hideVideo: ->
    @container.addClass('inactive')
    $.cookie(@cookieName, 1, { expires: 28, path: '/' })
    @player.stopVideo()

    $('body').off('*.introvideo')

  showVideo: ->
    @container.removeClass('inactive')
    @player.playVideo()
    @bindOnShow()


