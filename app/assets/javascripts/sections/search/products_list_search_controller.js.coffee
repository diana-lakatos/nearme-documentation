class Search.ProductsListSearchController extends Search.Controller
  constructor: (@form, @container) ->
    @initializeEndlessScrolling()
    @initializeSearchButton()
    @responsiveCategoryTree()
    @filters_container = $('[data-search-filters-container]')
    @loader = new Search.ScreenLockLoader => @container.find('.loading')
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

  reinitializePriceSlider: ->
    if $('#price-slider').length > 0
      @reinit = $('.search-max-price:first')
      noreinitSlider = parseInt( @reinit.attr('data-noreinit-slider') )
      
      max_price = @reinit.attr('data-max-price')
      @input_price_max = $("input[name='price[max]']")
      @input_price_max.val(max_price)

      @reinit_min = $('.search-max-price:last')
      min_price = @reinit_min.attr('data-min-price')
      @input_price_min = $("input[name='price[min]']")
      @input_price_min.val(min_price)

      @initializePriceSlider()
      @reinit.attr('data-noreinit-slider', 0)

  initializePriceSlider: =>
    elem = $('#price-slider')
    val = parseInt( $("input[name='price[max]']").val() )
    if val == 0
      val = parseInt( $('.search-max-price:first').attr('data-max-price') )

    start_val = parseInt( $("input[name='price[min]']").val() )
    if start_val == 0
      start_val = parseInt( $('.search-max-price:last').attr('data-min-price') )

    if val > @unfilteredPrice
      @unfilteredPrice = val
    
    elem.noUiSlider(
      start: [ start_val, val ],
      behaviour: 'drag',
      connect: true,
      range: {
        'min': 0,
        'max': @unfilteredPrice
      }
    )

    elem.on 'set', =>
      $('.search-max-price:first').attr('data-noreinit-slider', 1)
      $('.search-max-price:first').attr('data-max-price', elem.val()[1])
      @assignFormParams(
        'price[min]': elem.val()[0]
        'price[max]': elem.val()[1]
      )
      @triggerSearchFromQuery()

    elem.Link('upper').to('-inline-<div class="slider-tooltip"></div>', ( value ) ->
      $(this).html('<strong>$' + parseInt(value) + ' </strong>')
    )
    elem.Link('lower').to('-inline-<div class="slider-tooltip"></div>', ( value ) ->
      $(this).html('<strong>$' + parseInt(value) + ' </strong>')
    )

