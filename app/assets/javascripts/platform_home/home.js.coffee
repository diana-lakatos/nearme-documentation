class @HomeController

  constructor: ->
    @videoImgFallbackHeight = 457
    @videoImgFallbackWidth = 805
    @howItWorkTextBoxPadding = 80
    @videoEndTime = 14.0  # seconds

    @bindEvents()
    @startLaptopAnimation()
    @configureVideo()
    @resizeTextBoxes()
    @positionAnimation()
    @setLineWidth()

  bindEvents: =>
    $('.arrow a').click (e) ->
      content_top = $('section.create-and-manage').offset().top
      $('html, body').animate
        scrollTop: content_top
        900
      e.preventDefault()

    $('section.build-yours-now form#notify-me a').click (e) =>
      @submitNotifyMeForm()
      e.preventDefault()

    $('section.build-yours-now form').submit (e) =>
      @submitNotifyMeForm()
      e.preventDefault()

    $('section.build-yours-now .modal-footer a').on 'click', (e) =>
      @submitModalEmailShareForm()
      e.preventDefault()

    $('section.build-yours-now #email-modal form').submit (e) =>
      @submitModalEmailShareForm()
      e.preventDefault()

    $('section.build-yours-now ul li a').click (e) =>
      link_el = $(e.target).closest('a')
      @trackSocialShare(link_el)
      if link_el.parent().hasClass('popup')
        @popUpWindow(link_el.attr('href'), link_el.data('window-width'), link_el.data('window-height'))
      else
        $('#email-modal input').val('')
        $('#email-modal .modal-footer a').text('SEND')
        $('#email-modal').modal
          backdrop: true
          keyboard: true
      e.preventDefault()

    $('section.how-it-works .navigation a').click (e) ->
      link_el = $(e.target).closest('a')
      clearInterval(interval)  # stop autorotate
      if link_el.hasClass('left')
        spinner.moveTo(spinner.position - spinner.step)
      else
        spinner.moveTo(spinner.position + spinner.step)
      e.preventDefault()

    $(window).resize =>
      @setLineWidth()
      @resizeVideo()
      @resizeEmpower()
      @resizeCreateAndManage()
      @resizeTextBoxes()
      @positionAnimation()


  submitNotifyMeForm: ->
    form = $('section.build-yours-now form#notify-me')
    email = form.find('input[name=email]')
    if email.val() != ''
      $.post form.attr('action'),
        email: email.val()
        (response) ->
          form.replaceWith($(response))
          mixpanel.track("Submitted an email", { email: email.val() })
          ga('send', 'event', 'Form', 'Submitted an email')
    else
      email.effect("highlight", { color: 'rgb(231, 50, 66)' })


  submitModalEmailShareForm: ->
    form = $('section.build-yours-now form#send-email')
    emails = form.find('input[name=emails]')
    your_name = form.find('input[name=your_name]')

    if emails.val() != '' && your_name.val() != ''
      $('#email-modal .modal-footer a').text('SENDING ...')
      $.post form.attr('action'),
        email_data:
          emails: emails.val()
          your_name: your_name.val()
        (response) ->
          $('#email-modal .modal-footer a').text('SENT')
          $('#email-modal').modal('hide')
          mixpanel.track("Shared via email", { emails: emails.val() })
          ga('send', 'event', 'Form', 'Shared via email')
    else
      if emails.val() == ''
        emails.effect("highlight", { color: 'rgb(231, 50, 66)' })
      if your_name.val() == ''
        your_name.effect("highlight", { color: 'rgb(231, 50, 66)' })


  trackSocialShare: (link) ->
    ga('send', 'event', 'Link', 'Clicked a social sharing icon', link.data('network'))
    mixpanel.track("Clicked a social sharing icon", 'Social Network': link.data('network'))


  startLaptopAnimation: ->
    $('section.create-and-manage .input-left ul').simplyScroll
      orientation: 'vertical'
      direction: 'forwards'
      speed: 1
      frameRate: 36

    $('section.create-and-manage .input-right ul').simplyScroll
      orientation: 'vertical'
      direction: 'backwards'
      speed: 1
      frameRate: 36


  configureVideo: =>
    @resizeVideo()

    if /chrome/.test(navigator.userAgent.toLowerCase())
      # workaround for Chrome when server doesn't support requests that contain a "Range" header with a 206 "Partial Content" response
      video = $('video').get(0)
      video.addEventListener 'timeupdate', =>
        if video.currentTime > @videoEndTime
          video.load()
          video.play()
          video.removeEventListener('timeupdate')  # video in cache - don't need to track timeupdate event any more
      , false

      video.load()
      video.play()
    else
      $('video').get(0).play()


    @resizeCreateAndManage()
    setTimeout ( =>
      @resizeEmpower()
      $('.video_fallback').maximage()
    ), 1000


  resizeEmpower: ->
    $('.brands').css('height',$('.entrepreneurs').css('height'))


  resizeVideo: ->
    if $('video:visible').length > 0
      $('section.background-video').height('100%')
    else
      @setVideoFallbackSize()


  setVideoFallbackSize: =>
    if $('img.video_fallback').height() == 0
      # we have to wait for media queries to set element sizes
      setTimeout( =>
        @setVideoFallbackSize()
      , 200)
    else
      $('section.background-video').height($('img.video_fallback').height())


  resizeCreateAndManage: ->
    $('.laptop').height(@videoImgFallbackHeight * $('.laptop').width()/@videoImgFallbackWidth)


  positionAnimation: ->
    textBoxesHeight = $('section.how-it-works .boxes').height()
    wheelHeight = $('section.how-it-works .wheel').height()
    $('section.how-it-works .wheel').css('margin-top', textBoxesHeight/2 - wheelHeight/2)


  resizeTextBoxes: ->
    maxHeight = 0
    $('section.how-it-works .boxes .box').css('height', 'auto')  # let browser set height

    # get box with max height
    $('section.how-it-works .boxes .box').each ->
      box = $(this)
      if box.height() > maxHeight
        maxHeight = box.height()

    # set all boxes height with maxHeight plus top and bottom padding
    $('section.how-it-works .boxes .box').css('height', maxHeight + 2*@howItWorkTextBoxPadding)


  setLineWidth: ->
    textBoxesLeftPosition = $('section.how-it-works .boxes').offset().left
    lineLeft = parseInt($('section.how-it-works #line').css('left'))
    wheelLeftPosition = $('section.how-it-works .wheel').offset().left
    $('section.how-it-works #line').css('width', textBoxesLeftPosition - lineLeft - wheelLeftPosition)


  popUpWindow: (url, width, height, title = '') ->
    window_id = new Date().getTime()
    eval("page" + window_id + " = window.open('" + url + "', '" + window_id + "', 
      'toolbar=no,scrollbars=no,location=no,statusbar=no,menubar=no,resizable=no,width=" + width + ",height=" + height + ",left=" + parseInt($(window).width()/2 - width/2) +  ",top = " + parseInt($(window).height()/2 - height/2) +  "');")
