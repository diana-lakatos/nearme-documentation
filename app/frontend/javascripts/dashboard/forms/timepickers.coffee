require 'timepicker/jquery.timepicker'

timepickers = (context = 'body') ->
  $(context).find('input.time_picker').each ->
    input = $(this)
    input.timepicker({
      timeFormat: input.data('jsformat')
    })

    input.next('.input-group-addon').on 'click', ->
      input.timepicker('show')


module.exports = timepickers
