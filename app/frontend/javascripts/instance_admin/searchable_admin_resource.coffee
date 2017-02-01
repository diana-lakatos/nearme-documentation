module.exports = SearchableAdminResource =

  commonBindEvents: ->
    @container.find('#to, #from').datepicker()

    @container.on 'click', '#to, #from', (e) =>
      e.stopPropagation()

    @container.find('.date-dropdown').on 'click', 'li:not(.date-range)', ->
      parentContainer = $(@).closest('.filter')
      parentContainer.find('.date-dropdown').find('li.selected').removeClass('selected')
      $(@).addClass('selected')
      dateValue = $(@).find('a').data('date')
      selected = $(@).find('a').text()
      parentContainer.find('.dropdown-trigger .current').text(selected)
      parentContainer.find('.dropdown-trigger input[type="hidden"]').attr('value', dateValue)
      $(@).parents('form').submit()

    @container.find('.filter-value-dropdown').on 'click', 'li', ->
      filterValue = $(@).find('a').data('value')
      $(@).closest('.filter').find('.dropdown-trigger input[type="hidden"]').attr('value', filterValue)
      $(@).parents('form').submit()

    @container.find('.date-dropdown').on 'click', '.apply-filter', ->
      parentContainer = $(@).closest('.filter')
      startDate = parentContainer.find('#from').val()
      endDate = parentContainer.find('#to').val()
      if startDate && endDate
        parentContainer.find('input[type="hidden"]#date').val(startDate + '-' + endDate)
        $(@).parents('form').submit()

