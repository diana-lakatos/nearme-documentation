class Search.SearchNotificationController

  constructor: (@container)->
    @form = @container.find('form')
    @bindEvents()

  bindEvents: ->
    @form.submit =>
      $.post @form.attr('action'), @form.serialize(), (response)=>
        if response.status == 'success'
          window.location = '/'
        else
          @container.html(response)
      false
