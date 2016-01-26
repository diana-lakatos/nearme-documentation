module.exports = class SupportFaq

  constructor: (@container) ->
    $('.question', @container).on('click', (e) ->
      $(this).parent().toggleClass('opened')
      $(this).parent().toggleClass('closed')
    )
