class @InstanceAdmin.ReviewsController
  constructor: (@container) ->
    @bindEvents()

  bindEvents: ->
    @container.find('#to, #from').datepicker()

    @container.on 'click', '#to, #from', (e) =>
      e.stopPropagation()

    @container.on 'click', '.more-filters', =>
      @container.find('.filters-expanded').slideToggle()
      @container.find('.more-filters').toggleClass('active')
      @container.find('.more-filters .fa').toggleClass('fa-angle-right fa-angle-down')

    @container.find('.filters-expanded').on 'click', '.close-link', =>
      @container.find('.filters-expanded').slideUp()
      @container.find('.more-filters').removeClass('active')
      @container.find('.more-filters .fa').toggleClass('fa-angle-down fa-angle-right')

    @container.find('.date-dropdown').on 'click', 'li:not(.date-range)', ->
      $('.date-dropdown').find('li.selected').removeClass('selected')
      $(@).addClass('selected')
      dateValue = $(@).find('a').data('date')
      selected = $(@).find('a').text()
      $('.dropdown-trigger .current').text(selected)
      $('.dropdown-trigger input[type="hidden"]').attr('value', dateValue)
      $(@).parents('form').submit()

    @container.find('.date-dropdown').on 'click', '.apply-filter', ->
      startDate = $('#from').val()
      endDate = $('#to').val()
      if startDate && endDate
        $('input[type="hidden"]#date').val(startDate + '-' + endDate)
        $(@).parents('form').submit()
