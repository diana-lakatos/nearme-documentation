SearchController = require('./controller')

module.exports = class SearchProductsTableSearchController extends SearchController
  constructor: (@form, @container) ->
    @initializeSearchButton()
    @responsiveCategoryTree()
    @filters_container = $('[data-search-filters-container]')
    @unfilteredPrice = 0
    @bindEvents()

    @initializePriceSlider()

  bindEvents: ->
    @filters_container.on 'click', 'input[type=checkbox]', =>
      setTimeout =>
        @triggerSearchFromQuery()
        100

  triggerSearchFromQuery: (page = false) ->
    @assignFormParams(
      ignore_search_event: 0
      category_ids: _.toArray(@container.find('input[name="category_ids[]"]:checked').map(-> $(this).val())).join(',')
      page: page || 1
    )
    @form.submit()

  initializeSearchButton: ->
    $(".span12 .search-icon").click ->
      $("form.search_results").submit()
