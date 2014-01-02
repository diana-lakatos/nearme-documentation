class Search.SearchMixedController extends Search.SearchController

  constructor: (form, @container) ->
    @resultsContainer = => @container.find('.locations')
    @hiddenResultsContainer = => @container.find('.hidden-locations')
    @sortField = @container.find('#sort')
    super(form, @container)
    @adjustListHeight()
    @sortValue = @sortField.find(':selected').val()

  bindEvents: =>
    super
    $(window).resize =>
      @adjustListHeight()

    @sortField.on 'change', =>
      if @sortValue != @sortField.find(':selected').val()
        @sortValue = @sortField.find(':selected').val()
        @fieldChanged()

  adjustListHeight: ->
    list_container = @container.find('.list')
    list_container.height($(window).height() - list_container.offset().top)


  initializeMap: ->
    super
    @map.clusterer.addListener 'click', (cluster) =>
      @processingResults = true
      listings = _.map(cluster.getMarkers(), (marker) => @map.getListingForMarker(marker))
      list_container = @container.find('.list')
      animate_position = @resultsContainer().find('div.listing[data-id="' + listings[0]._id + '"]').parents('.location').position().top + list_container.offset().top
      list_container.animate
        scrollTop: animate_position
        () =>
          @processingResults = false

    google.maps.event.addListener @map.googleMap, 'zoom_changed', =>
      @map.clusterer.setZoomOnClick(false)


  getListingsFromResults: ->
    listings = []
    @hiddenResultsContainer().find('article.listing').each (i, el) =>
      listing = @listingForElementOrBuild(el)
      listings.push listing
    listings


  initializeEndlessScrolling: ->
    $('.list').scrollTop(0)
    jQuery.ias({
      container : 'div.locations',
      item: 'article.location',
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


  # Trigger the API request for search
  #
  # Returns a jQuery Promise object which can be bound to execute response semantics.
  triggerSearchRequest: ->
    @currentAjaxRequest.abort() if @currentAjaxRequest
    @currentAjaxRequest = $.ajax(
      url  : @form.attr("action")
      type : 'GET',
      data : @form.add('.list .sort :input').serialize()
    )


  # Trigger the search from manipulating the query.
  # Note that the behaviour semantics are different to manually moving the map.
  triggerSearchFromQuery: ->
    # assign filter values
    @assignFormParams(
      lntype: _.toArray(@container.find('input[name="location_types_ids[]"]:checked').map(-> $(this).val())).join(',')
      lgtype: _.toArray(@container.find('input[name="listing_types_ids[]"]:checked').map(-> $(this).val())).join(',')
      lgpricing: _.toArray(@container.find('input[name="listing_pricing[]"]:checked').map(-> $(this).val())).join(',')
      sort: @container.find('#sort').val()
      loc: @form.find("input#search").val().replace(', United States', '')
    )
    super


  updateResultsCount: ->
    count = parseInt(@hiddenResultsContainer().find('input#result_count').val())
    inflection = 'location'
    inflection += 's' unless count == 1
    @resultsCountContainer.html("<span>#{count}</span> #{inflection}")


  updateMapWithListingResults: ->
    @map.markers = {}
    @map.clusterer.clearMarkers()
    @map.popover.close()

    listings = @getListingsFromResults()

    if listings? and listings.length > 0
      @map.plotListings(listings)

      # Only show bounds of new results
      bounds = new google.maps.LatLngBounds()
      bounds.extend(listing.latLng()) for listing in listings
      _.defer => @map.fitBounds(bounds)

      @map.show()

      # In case the map is hidden
      @map.resizeToFillViewport()
    setTimeout( =>
      @map.clusterer.redraw_()
    , 500)


  # Within the current map display, plot the listings from the current results. Remove listings
  # that aren't within the current map bounds from the results.
  plotListingResultsWithinBounds: ->
    @map.markers = {}
    @map.clusterer.clearMarkers()
    super
    @map.clusterer.redraw_()


  showResults: (html) ->
    super(html)
    @updateResultsCount()
    $('.list').scrollTop(0)


  # Trigger automatic updating of search results
  fieldChanged: (field, value) ->
    @triggerSearchFromQueryAfterDelay()


  updateUrlForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()
    # we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
    # to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
    url = decodeURIComponent("?#{$.param(params)}")
    History.replaceState(params, @container.find('input[name=meta_title]').val(), url)
