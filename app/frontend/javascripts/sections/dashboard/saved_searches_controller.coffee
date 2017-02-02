urlUtil = require('../../lib/utils/url')

module.exports = class DashboardSavedSearchController
  constructor: (@container) ->
    @bindEvents()

  bindEvents: =>
    @bindAlertsFrequency()
    @bindEditLinks()
    @bindTitleSubmits()

  bindAlertsFrequency: ->
    $('select[data-alerts-frequency]').on 'change', (event) ->
      input = $(event.target)
      $.ajax
        url: input.closest('form').attr('action')
        type: 'PATCH'
        data: {alerts_frequency: input.val()}

  bindEditLinks: ->
    $('a[data-saved-search-edit-id]').on 'click', (event) ->
      event.preventDefault()

      savedSearchId = $(@).data('saved-search-edit-id')
      titleCol = $("td[data-saved-search-title=#{savedSearchId}]")
      link = titleCol.find('a')
      title = link.text()
      link.hide()
      $('<input/>').attr(type: 'text', name: 'title', 'data-saved-search-id': savedSearchId).val(title).appendTo(titleCol).focus()


  bindTitleSubmits: =>
    $('table[data-saved-searches]').on 'focusout keyup', 'input[data-saved-search-id]', (event) =>
      self = $(event.target)
      if (typeof event.keyCode == 'undefined' || event.keyCode == 13)
        event.preventDefault()
        @submitTitle(self)


  submitTitle: (input) =>
    container = input.parent()
    link = container.find('a')
    if !$.trim(input.val()) || input.val() == link.text()
      input.remove()
      link.show()
    else
      title = input.val()
      input.remove()
      $.ajax
        url: '/dashboard/saved_searches/' + input.data('saved-search-id')
        type: 'PUT'
        dataType: 'JSON'
        data: {saved_search: {title: title}}
        success: (data) =>
          @showNewTitle(container, data['success'], data['title'])
        error: =>
          @showNewTitle(container, false)


  showNewTitle: (container, success, title = null) ->
    link = container.find('a')
    link.text(title) if success
    link.show()

    imgSuccessUrl = urlUtil.assetUrl("dashboard/green-check.png")
    imgErrorUrl   = urlUtil.assetUrl("dashboard/x-red.png")
    imgUrl = if success then imgSuccessUrl else imgErrorUrl
    img = $('<img>').attr('src', imgUrl).addClass('status').hide()
    container.append(img)
    img.fadeIn('slow', -> img.fadeOut('slow', -> img.remove()))
