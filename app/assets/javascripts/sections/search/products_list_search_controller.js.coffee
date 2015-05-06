class Search.ProductsListSearchController extends Search.Controller
  constructor: (@form, @container) ->
    @initializeEndlessScrolling()
    @initializeSearchButton()
    @responsiveCategoryTree()
    @filters_container = $('nav[data-search-filters-container]')
    @loader = new Search.ScreenLockLoader => @container.find('.loading')

    @bindEvents()

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
    @loader.showWithoutLocker()
    @form.submit()

  initializeSearchButton: ->
    @searchButton = @form.find(".search-icon")
    if @searchButton.length > 0
      @searchButton.bind 'click', =>
        @form.submit()

  initializeEndlessScrolling: ->
      $('#results').scrollTop(0)
      jQuery.ias({
        container : '#results',
        item: '.product',
        pagination: '.pagination',
        next: '.next_page',
        triggerPageThreshold: 99,
        history: false,
        thresholdMargin: -90,
        loader: '<div class="row-fluid span12"><h1><img src="' + $('img[alt=Spinner]').eq(0).attr('src') + '"><span>Loading More Results</span></h1></div>'
      })

