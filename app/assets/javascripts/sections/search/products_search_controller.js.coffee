class Search.ProductsSearchController extends Search.Controller
  constructor: (@form, @container) ->
    @redirectIfNecessary()
    @loader = new Search.ScreenLockLoader => @container.find('.loading')
    @resultsContainer ||= => @container.find('#results')
    @bindEvents()

  bindEvents: ->
    @form.bind 'submit', (event) =>
      event.preventDefault()
      @triggerSearchFromQuery()

    @searchField = @form.find('#search')
    @searchField.on 'focus', => $(@form).addClass('query-active')
    @searchField.on 'blur', => $(@form).removeClass('query-active')

    @searchButton = @form.find(".search-icon")
    if @searchButton.length > 0
      @searchButton.bind 'click', =>
        @form.submit()


  # for browsers without native html 5 support for history [ mainly IE lte 9 ] the url looks like:
  # /search?q=OLDQUERY#search?q=NEWQUERY. Initially, results are loaded for OLDQUERY.
  # This methods checks, if OLDQUERY == NEWQUERY, and if not, it redirect to the url after #
  # [ which is stored in History.getState() and contains NEWQUERY ].
  # Updating the form instead of redirecting could be a little bit better,
  # but there are issues with updating google maps view etc. - remember to check it if you update the code
  redirectIfNecessary: ->
    if History.getState() && !window.history?.replaceState
      for k, param of History.getState().data
        if param.name == 'loc'
          if param.value != DNM.util.Url.getParameterByName('loc')
            document.location = History.getState().url


  initializeEndlessScrolling: ->
    $('#results').scrollTop(0)
    jQuery.ias({
      container : '#results',
      item: '.listing',
      pagination: '.pagination',
      next: '.next_page',
      triggerPageThreshold: 99,
      history: false,
      thresholdMargin: -90,
      loader: '<div class="row-fluid span12"><h1><img src="' + $('img[alt=Spinner]').eq(0).attr('src') + '"><span>Loading More Results</span></h1></div>',
      onRenderComplete: (items) =>
        @initializeConnectionsTooltip()
        # when there are no more resuls, add special div element which tells us, that we need to reinitialize ias - it disables itself on the last page...
        if !$('#results .pagination .next_page').attr('href')
          $('#results').append('<div id="reinitialize"></div>')
          reinitialize = $('#reinitialize')
    })


  showResults: (html) ->
    @resultsContainer().replaceWith(html)
    $('.pagination').hide()

  updateResultsCount: ->
    count = @resultsContainer().find('.listing:not(.hidden)').length
    inflection = 'result'
    inflection += 's' unless count == 1
    @resultsCountContainer.html("#{count} #{inflection}")


  # Return Search.Listing objects from the search results.
  getListingsFromResults: ->
    listings = []
    @resultsContainer().find('.listing').each (i, el) =>
      listing = @listingForElementOrBuild(el)
      listings.push listing
    listings


  # Trigger the search from manipulating the query.
  # Note that the behaviour semantics are different to manually moving the map.
  triggerSearchFromQuery: ->
    # we want to log any new search query
    @assignFormParams(
      ignore_search_event: 0
    )
    @loader.showWithoutLocker()
     # Infinite-Ajax-Scroller [ ias ] which we use disables itself when there are no more results
     # we need to reenable it when it is necessary, and only then - otherwise we will get duplicates
    if $('#reinitialize').length > 0
      @initializeEndlessScrolling()
    @triggerSearchAndHandleResults()


  # Triggers a search with default UX behaviour and semantics.
  triggerSearchAndHandleResults: (callback) ->
    @loader.showWithoutLocker()
    @triggerSearchRequest().success (html) =>
      @processingResults = true
      @showResults(html)
      @updateUrlForSearchQuery()
      @updateLinksForSearchQuery()
      window.scrollTo(0, 0)
      @loader.hide()
      callback() if callback
      _.defer => @processingResults = false


  # Trigger the API request for search
  #
  # Returns a jQuery Promise object which can be bound to execute response semantics.
  triggerSearchRequest: ->
    $.ajax(
      url  : @form.attr("action")
      type : 'GET',
      data : @form.serialize()
    )

  triggerListingsRequest: (listings) =>
    listing_ids = (listing.id() for listing in listings).toString()
    $.ajax(
      url  : '/search/show/' + listing_ids + '?v=map'
      type : 'GET'
    )


  updateUrlForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()
    # we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
    # to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
    url = decodeURIComponent("?#{$.param(params)}")
    History.replaceState(params, "Search Results", url)

  updateLinksForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()

    $('.list-map-toggle a', @form).each ->
      for k, param of params
        if param["name"] == 'v'
          param["value"] = (if $(this).hasClass('map') then 'mixed' else 'list')
      _url = "#{url}?#{$.param(params)}&ignore_search_event=1"
      $(this).attr('href', _url)
