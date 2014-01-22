class @GetInTouchController

  constructor: ->
    @bindEvents()

  bindEvents: ->
    $('input, textarea').on 'keyup keydown keypress change paste', ->
      if $(this).val() is ""
        $(this).addClass('incomplete')
      else
        $(this).removeClass('incomplete')

    $('section.get-in-touch form').submit (e) =>
      @sendGetInTouchForm()
      e.preventDefault()

  sendGetInTouchForm: ->
    form = $('section.get-in-touch form')
    email = form.find('input#email')
    name = form.find('input#name')
    industry = form.find('input#industry')

    if name.val() != '' and email.val() != ''
      $.ajax
        url: form.attr('action')
        method: 'POST'
        data: form.serialize()
        success: (response) ->
          if response.status
            mixpanel.track("Submitted a question", { industry: industry.val() })
            ga('send', 'event', 'Form', 'Submitted a question', industry.val())
            form.replaceWith($(response.body))
            $('section.get-in-touch').find('.title.warning').hide()
          else
            $('section.get-in-touch').find('.title.normal').addClass('hidden')
            $('section.get-in-touch').find('.title.warning').html(response.body).removeClass('hidden')
        dataType: 'json'

    else
      $('section.get-in-touch').find('.title.normal').addClass('hidden')
      $('section.get-in-touch').find('.title.warning').removeClass('hidden')
