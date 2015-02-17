previous_value = $('#instance_wish_lists_icon_set').val()

$('#instance_wish_lists_icon_set').change ->
  icon_set = $('#instance_wish_lists_icon_set').val()

  $("#set-" + previous_value).hide(0, ->
    $("#set-" + icon_set).show 0
    previous_value = icon_set
  )

  return
