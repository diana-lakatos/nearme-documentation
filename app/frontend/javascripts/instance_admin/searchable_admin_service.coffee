module.exports = SearchableAdminService =

  serviceBindEvents: ->
    @container.find('.item-type-dropdown').on 'click', 'li', ->
      parentContainer = $(@).closest('.filter')
      parentContainer.find('li.selected').removeClass('selected')
      $(@).addClass('selected')
      itemTypeValue = $(@).find('a').data('item-type-id')
      selected = $(@).find('a').text()
      parentContainer.find('.dropdown-trigger .current').text(selected)
      parentContainer.find('.dropdown-trigger input[type="hidden"]').attr('value', itemTypeValue)
      $(@).parents('form').submit()

    @container.find('a[data-download-report]').on 'click', (e) ->
      formParameters = $(@).closest('form').serialize()
      reportUrl = $(@).data('report-url')
      location.href = reportUrl + '?' + formParameters
      e.preventDefault()

