class @RatingForm

  constructor: () ->
    @bindEvents()

  bindEvents: ->
    $('.thumbs img').click (event) =>
      event.preventDefault()
      $clicked_thumb = $(event.target)
      $container = $clicked_thumb.closest('.thumbs')
      $thumbs = $container.find('img')
      $hidden_field = $container.find('input[type=hidden]')

      $hidden_field.val($clicked_thumb.data('value'))
      $thumbs.removeClass('active').addClass('inactive')
      $clicked_thumb.removeClass('inactive').addClass('active')
