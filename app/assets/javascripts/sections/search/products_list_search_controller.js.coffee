class Search.ProductsListSearchController
  constructor: (@form, @container) ->
    @initializeEndlessScrolling()
    @initializeSearchButton()

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

