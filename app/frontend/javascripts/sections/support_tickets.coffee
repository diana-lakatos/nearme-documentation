require('jquery-inview/jquery.inview')

module.exports = class SupportTickets

  constructor: (@container) ->
    $(@container).on 'inview', (e, visible) ->
      return unless visible

      $.getScript $(this).attr('href')
