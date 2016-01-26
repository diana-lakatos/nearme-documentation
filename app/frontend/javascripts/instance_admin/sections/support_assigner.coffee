module.exports = class SupportAssigner

  constructor: (@container) ->
    $(@container).on 'change', ->
      url = window.location.href
      val = $(this).val()

      $('legend.status').html('saving...')
      $('.support select').prop('disabled', 'disabled')

      $.ajax
        data: {assigned_to_id: val}
        url: url
        type: 'PUT'
        success: ->
          $('legend.status').html('saved')
          $('.support select').prop('disabled', false)
          setTimeout (->
            $('legend.status').html('')
          ) , 5000

