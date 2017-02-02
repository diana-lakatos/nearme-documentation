require('history.js/history')
require('history.js/history.adapter.ender')
SearchController = require('./controller')
urlUtil = require('../../lib/utils/url')
SearchScreenLockLoader = require('./screen_lock_loader')

window.IASCallbacks = require('exports?IASCallbacks!../../vendor/jquery-ias/callbacks')
require('../../vendor/jquery-ias/jquery-ias')

module.exports = class SearchProductsSearchController extends SearchController
  constructor: (@form, @container) ->
    @redirectIfNecessary()
    @loader = new SearchScreenLockLoader => @container.find('.loading')
    @resultsContainer ||= => @container.find('#results')
    @perPageField = @container.find('select#per_page')
    @filters_container = $('div[data-search-filters-container]')
    @unfilteredPrice = 0

    @bindEvents()
    @performEndlessScrolling = @form.data('endless-scrolling')
    @initializeEndlessScrolling()
    @reinitializeEndlessScrolling = false
    @perPageValue = @perPageField.find(':selected').val()
    @submitFormWithoutAjax = false
    @responsiveCategoryTree()
    @initializePriceSlider()

    @autocompleteCategories()

  bindEvents: ->
    @filters_container.on 'click', 'input[type=checkbox]:not(.nav-heading > label > input)', =>
      @triggerSearchFromQuery()

    $(document).on 'change', '.search-attribute-filter select', (e) =>
      @perPageValue = @perPageField.find(':selected').val()
      @triggerSearchFromQuery()

    @form.bind 'submit', (event) =>
      if @submitFormWithoutAjax == false
        event.preventDefault()
        @triggerSearchFromQuery()

    @searchField = @form.find('#search')
    @searchField.on 'focus', => $(@form).addClass('query-active')
    @searchField.on 'blur', => $(@form).removeClass('query-active')

    @searchButton = @form.find(".search-icon")
    if @searchButton.length > 0
      @searchButton.bind 'click', =>
        @form.submit()

    $(document).on 'click', '.pagination a', (e) =>
      e.preventDefault()
      link = $(e.target)
      if link.attr('href') == undefined
        link = link.parents('a')
      page_regexp = /page=(\d+)/gm
      @loader.show()
      @triggerSearchFromQuery(page_regexp.exec(link.attr('href'))[1])

    $(document).on 'click', 'a.clear-filters', (e) =>
      e.preventDefault()
      @submitFormWithoutAjax = true
      @assignFormParams()
      @form.submit()

  rebindForm: ->
    @container.find('select').select2({ allowClear: true })
    @form = $('#search_form')
    @performEndlessScrolling = @form.data('endless-scrolling')
    @form.bind 'submit', (event) =>
      if @submitFormWithoutAjax == false
        event.preventDefault()
        @triggerSearchFromQuery()

    @searchField = @form.find('#search')
    @searchField.on 'focus', => $(@form).addClass('query-active')
    @searchField.on 'blur', => $(@form).removeClass('query-active')

    @searchButton = @form.find(".search-icon")
    if @searchButton.length > 0
      @searchButton.bind 'click', =>
        @form.submit()

    $(document).on 'click', 'a.clear-filters', (e) =>
      e.preventDefault()
      @submitFormWithoutAjax = true
      @assignFormParams()
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
          if param.value != urlUtil.getParameterByName('loc')
            document.location = History.getState().url


  initializeEndlessScrolling: ->
    if @performEndlessScrolling
      $('#results').scrollTop(0)
      ias = jQuery.ias({
        container : '#results',
        item: '.product',
        pagination: '.pagination',
        next: '.next_page',
        triggerPageThreshold: 99,
        history: false,
        thresholdMargin: -90,
        loader: '<div class="row-fluid span12"><h1><img src="' + $('img[alt=Spinner]').eq(0).attr('src') + '"><span>Loading More Results</span></h1></div>',
        onRenderComplete: (items) ->
          # when there are no more resuls, add special div element which tells us, that we need to reinitialize ias - it disables itself on the last page...
          if !$('#results .pagination .next_page').attr('href')
            $('#results').append('<div id="reinitialize"></div>')
            reinitialize = $('#reinitialize')
      })

      ias.on 'rendered', (items) ->
        $(document).trigger('rendered-search:ias.nearme', [items])


  showResults: (html) ->
    @resultsContainer().replaceWith(html)

    if @performEndlessScrolling
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
  triggerSearchFromQuery: (page = false) ->

    category_ids = _.toArray(@container.find('input[name="category_ids[]"]:checked').map(-> $(this).val()))
    @container.find('input[data-category-autocomplete]').each ->
      category_ids = category_ids.concat($(this).val().split(','))

    # we want to log any new search query
    @assignFormParams(
      ignore_search_event: 0
      per_page: @container.find('select#per_page').val()
      category_ids: category_ids.join(',')
      loc: @form.find("input#search").val()
      page: page || 1
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
      @rebindForm()
      @updatePriceSlider()
      @loader.hide()
      callback() if callback
      _.defer => @processingResults = false


  # Trigger the API request for search
  #
  # Returns a jQuery Promise object which can be bound to execute response semantics.
  triggerSearchRequest: ->
    @currentAjaxRequest.abort() if @currentAjaxRequest
    @currentAjaxRequest = $.ajax(
      url  : @form.attr("action")
      type : 'GET',
      data : @form.serialize()
    )

  updateUrlForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()
    filtered_params = []
    for k, param of params
      if $.inArray(param["name"], ['ignore_search_event', 'country', 'v'] ) < 0
        filtered_params.push {name: param["name"], value: param["value"]}

    # we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
    # to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
    url = decodeURIComponent("?#{$.param(filtered_params)}")
    History.replaceState(params, @container.find('input[name=meta_title]').val(), url)


  updateLinksForSearchQuery: ->
    url = document.location.href.replace(/\?.*$/, "")
    params = @getSearchParams()


  getSearchParams: ->
    form_params = @form.serializeArray()
    form_params = @replaceWithData(form_params)
    # don't polute url if this is unnecessary - ignore empty values and page
    params = []
    for k, param of form_params
      params.push(param)
    params

  autocompleteCategories: ->
    self = this
    return unless @container.find("input[data-category-autocomplete]").length > 0

    $.each @container.find("input[data-category-autocomplete]"), (index, select) ->

      selected = JSON.parse($(select).attr("data-selected-categories"))
      apiUrl = $(select).attr('data-api-category-path')

      $(select).select2(
        multiple: true
        initSelection: (element, callback) ->
          url = apiUrl
          $.getJSON url, { init_selection: 'true', ids: selected }, (data) ->
            callback data

        ajax:
          url: apiUrl
          datatype: "json"
          data: (term, page) ->
            per_page: 50
            page: page
            q:
              name_cont: term

          results: (data, page) ->
            results: data

        formatResult: (category) ->
          category.translated_name

        formatSelection: (category) ->
          category.translated_name
      ).on('change', (e) ->
        self.triggerSearchFromQuery()
      ).select2('val', selected.join(','))
