$('.favorite #action-link').on 'click', (e) ->
  if $('#action-link').attr('data-current-user') == 'true'
    e.preventDefault()
    $.getScript $(this).attr 'href'

  return
