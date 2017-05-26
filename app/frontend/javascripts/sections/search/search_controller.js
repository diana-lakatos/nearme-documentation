/* global google */
var SearchController,
  SearchListing,
  SearchMap,
  SearchRangeDatePickerFilter,
  SearchRedoSearchMapControl,
  SearchResultsGoogleMapController,
  SearchScreenLockLoader,
  SearchSearchController,
  urlUtil,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  },
  extend = function(child, parent) {
    for (var key in parent) {
      if (hasProp.call(parent, key)) child[key] = parent[key];
    }
    function ctor() {
      this.constructor = child;
    }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
    return child;
  },
  hasProp = {}.hasOwnProperty;

require('history.js/history');

require('history.js/history.adapter.ender');

SearchController = require('./controller');

SearchScreenLockLoader = require('./screen_lock_loader');

SearchResultsGoogleMapController = require('./search_results_google_map_controller');

SearchRangeDatePickerFilter = require('./range_datepicker_filter');

SearchRedoSearchMapControl = require('./redo_search_map_control');

SearchListing = require('./listing');

SearchMap = require('./map');

urlUtil = require('../../lib/utils/url');

window.IASCallbacks = require('exports?IASCallbacks!../../vendor/jquery-ias/callbacks');

require('../../vendor/jquery-ias/jquery-ias');

/*
 * Controller for Search results and filtering page
 *
 * FIXME: This and the home search form should be separate. Instead we should abstract out
 *        a common "search query" input field which handles the geolocation of the query,
 *        and notifies observers when it is changed.
 */
SearchSearchController = (function(superClass) {
  extend(SearchSearchController, superClass);

  function SearchSearchController(form, container) {
    this.container = container;
    this.bindMapEvents = bind(this.bindMapEvents, this);
    this.resultsContainer = bind(this.resultsContainer, this);
    SearchSearchController.__super__.constructor.call(this, form, this.container);
    this.redirectIfNecessary();
    this.initializeDateRangeField();
    this.listings = {};
    this.loader = new SearchScreenLockLoader(() => {
      return this.container.find('.loading');
    });
    this.resultsCountContainer = $('#search_results_count');
    this.transactable_types = $('div[data-transactable-type-filter] input');
    this.date_range = $('div[data-date-range-filter] input');
    this.date_range_btn = $('div[data-date-range-filter] div[data-date-range-filter-update]');
    this.filters = $('a[data-search-filter]');
    this.filters_container = $('[data-search-filters-container]');
    this.movableGoogleMap = $('#search-result-movable-google-map');
    if (this.movableGoogleMap.length > 0) {
      new SearchResultsGoogleMapController(this.resultsContainer(), this.movableGoogleMap);
    }
    this.processingResults = true;
    this.initializeMap();
    this.bindEvents();
    this.initializeEndlessScrolling();
    this.initializeConnectionsTooltip();
    setTimeout(
      (function(_this) {
        return function() {
          return (_this.processingResults = false);
        };
      })(this),
      1000
    );
    this.responsiveCategoryTree();
    this.updateLinks();
    if ($('.load-more', this.container).length) {
      this.initLoadMoreButton();
    }
  }

  SearchSearchController.prototype.resultsContainer = function() {
    return this.container.find('#results');
  };

  SearchSearchController.prototype.bindEvents = function() {
    this.form.bind(
      'submit',
      (function(_this) {
        return function(event) {
          event.preventDefault();
          return _this.triggerSearchFromQuery();
        };
      })(this)
    );
    this.transactable_types.on(
      'change',
      (function(_this) {
        return function(event) {
          var params;
          _this.form.find('input[name="transactable_type_id"]').val($(event.target).val());
          params = decodeURIComponent('?' + $.param(_this.getSearchParams()));
          return (document.location = window.location.href =
            document.location.protocol +
            '//' +
            document.location.host +
            document.location.pathname +
            params);
        };
      })(this)
    );
    this.date_range_btn.on(
      'click',
      (function(_this) {
        return function() {
          return _this.triggerSearchFromQuery();
        };
      })(this)
    );
    this.closeFilterIfClickedOutside();
    this.filters.on(
      'click',
      (function(_this) {
        return function(event) {
          /*
         * allow to hide already opened element
         */
          if ($(event.currentTarget).parent().find('ul').is(':visible')) {
            _this.hideFilters();
          } else {
            _this.hideFilters();
            $(event.target).closest('.search-filter').find('ul').toggle();
            $(event.target).closest('.search-filter').toggleClass('active');
          }
          return false;
        };
      })(this)
    );
    this.filters_container.on(
      'click',
      'input[type=checkbox]:not(.nav-heading > label > input), input[type=radio]',
      (function(_this) {
        return function(event) {
          if ($(event.target).attr('name') === 'parent_category_ids[]') {
            return;
          }
          return _this.fieldChanged();
        };
      })(this)
    );
    this.filters_container.on(
      'change',
      'input[type=text], select',
      (function(_this) {
        return function() {
          return _this.fieldChanged();
        };
      })(this)
    );
    this.searchField = this.form.find('#search');
    this.searchField.on(
      'focus',
      (function(_this) {
        return function() {
          return $(_this.form).addClass('query-active');
        };
      })(this)
    );
    this.searchField.on(
      'blur',
      (function(_this) {
        return function() {
          return $(_this.form).removeClass('query-active');
        };
      })(this)
    );
    if (this.map != null) {
      return this.bindMapEvents();
    }
  };

  SearchSearchController.prototype.bindMapEvents = function() {
    this.map.on(
      'click',
      (function(_this) {
        return function() {
          return _this.searchField.blur();
        };
      })(this)
    );
    return this.map.on(
      'viewportChanged',
      (function(_this) {
        return function() {
          /*
         * NB: The viewport can change during 'query based' result loading, when the map fits
         *     the bounds of the search results. We don't want to trigger a bounding box based
         *     lookup during a controlled viewport change such as this.
         */
          if (_this.processingResults) {
            return;
          }
          if (!_this.redoSearchMapControl.isEnabled()) {
            return;
          }
          return _this.triggerSearchWithBoundsAfterDelay();
        };
      })(this)
    );
  };

  SearchSearchController.prototype.hideFilters = function() {
    var filter, j, len, ref, results;
    ref = this.filters;
    results = [];
    for ((j = 0), (len = ref.length); j < len; j++) {
      filter = ref[j];
      $(filter).parent().find('ul').hide();
      results.push($(filter).parent().removeClass('active'));
    }
    return results;
  };

  SearchSearchController.prototype.closeFilterIfClickedOutside = function() {
    return $('body').on(
      'click',
      (function(_this) {
        return function(event) {
          if ($(_this.filters_container).has(event.target).length === 0) {
            return _this.hideFilters();
          }
        };
      })(this)
    );
  };

  /*
   * for browsers without native html 5 support for history [ mainly IE lte 9 ] the url looks like:
   * /search?q=OLDQUERY#search?q=NEWQUERY. Initially, results are loaded for OLDQUERY.
   * This methods checks, if OLDQUERY == NEWQUERY, and if not, it redirect to the url after #
   * [ which is stored in History.getState() and contains NEWQUERY ].
   * Updating the form instead of redirecting could be a little bit better,
   * but there are issues with updating google maps view etc. - remember to check it if you update the code
   */
  SearchSearchController.prototype.redirectIfNecessary = function() {
    var k, param, ref, results;
    if (History.getState && !window.history.replaceState) {
      ref = History.getState().data;
      results = [];
      for (k in ref) {
        param = ref[k];
        if (param.name === 'loc') {
          if (param.value !== urlUtil.getParameterByName('loc')) {
            results.push((document.location = History.getState().url));
          } else {
            results.push(void 0);
          }
        } else {
          results.push(void 0);
        }
      }
      return results;
    }
  };

  SearchSearchController.prototype.initializeDateRangeField = function() {
    return (this.rangeDatePicker = new SearchRangeDatePickerFilter(
      this.form.find('.availability-date-start'),
      this.form.find('.availability-date-end'),
      (function(_this) {
        return function(dates) {
          return _this.fieldChanged('dateRange', dates);
        };
      })(this)
    ));
  };

  SearchSearchController.prototype.initializeEndlessScrolling = function() {
    var ias;
    $('#results').scrollTop(0);
    ias = jQuery.ias({
      container: '#results',
      item: '.listing',
      pagination: '.pagination',
      next: '.next_page',
      triggerPageThreshold: 99,
      history: false,
      thresholdMargin: -90,
      loader: '<div class="row-fluid span12"><h1><img src="' +
        $('img[alt=Spinner]').eq(0).attr('src') +
        '"><span>Loading More Results</span></h1></div>',
      onRenderComplete: (function(_this) {
        return function() {
          return _this.initializeConnectionsTooltip();
        };
      })(this)
    });
    return ias.on('rendered', function(items) {
      return $(document).trigger('rendered-search:ias.nearme', [items]);
    });
  };

  SearchSearchController.prototype.initializeMap = function() {
    var mapContainer, resizeMapThrottle;
    mapContainer = this.container.find('#listings_map')[0];
    if (!mapContainer) {
      return;
    }
    this.map = new SearchMap(mapContainer, this);

    /*
     * Add our map viewport search control, which enables/disables searching on map move
     */
    this.redoSearchMapControl = new SearchRedoSearchMapControl({
      enabled: true,
      update_text: $(mapContainer).data('update-text')
    });
    this.map.addControl(this.redoSearchMapControl);
    resizeMapThrottle = _.throttle(
      (function(_this) {
        return function() {
          return _this.map.resizeToFillViewport();
        };
      })(this),
      200
    );
    $(window).resize(resizeMapThrottle);
    $(window).trigger('resize');
    return this.updateMapWithListingResults();
  };

  SearchSearchController.prototype.showResults = function(html) {
    var wrap;
    wrap = $('<div>' + html + '</div>');
    html = wrap.find('#results');
    this.resultsContainer().replaceWith(html);
    this.resultsContainer()
      .find('input[data-authenticity-token]')
      .val($('meta[name="authenticity_token"]').attr('content'));
    $('.pagination').hide();
    return this.updateResultsCount();
  };

  SearchSearchController.prototype.updateResultsCount = function() {
    var count, inflection;
    count = this.resultsContainer().find('.listing:not(.hidden)').length;
    inflection = 'result';
    if (count !== 1) {
      inflection += 's';
    }
    return this.resultsCountContainer.html('<b>' + count + '</b> ' + inflection);
  };

  /*
   * Update the map with the current listing results, and adjust the map display.
   */
  SearchSearchController.prototype.updateMapWithListingResults = function() {
    var bounds, j, len, listing, listings;
    this.map.popover.close();
    listings = this.getListingsFromResults();
    if (listings != null && listings.length > 0) {
      this.map.plotListings(listings);

      /*
       * Only show bounds of new results
       */
      bounds = new google.maps.LatLngBounds();
      for ((j = 0), (len = listings.length); j < len; j++) {
        listing = listings[j];
        bounds.extend(listing.latLng());
      }
      bounds.extend(
        new google.maps.LatLng(
          this.form.find('input[name=lat]').val(),
          this.form.find('input[name=lng]').val()
        )
      );
      _.defer(
        (function(_this) {
          return function() {
            return _this.map.fitBounds(bounds);
          };
        })(this)
      );
      this.map.show();

      /*
       * In case the map is hidden
       */
      return this.map.resizeToFillViewport();
    } else {
      return this.map.hide();
    }
  };

  /*
   * Within the current map display, plot the listings from the current results. Remove listings
   * that aren't within the current map bounds from the results.
   */
  SearchSearchController.prototype.plotListingResultsWithinBounds = function() {
    var j, len, listing, ref, wasPlotted;
    ref = this.getListingsFromResults();
    for ((j = 0), (len = ref.length); j < len; j++) {
      listing = ref[j];
      wasPlotted = this.map.plotListingIfInMapBounds(listing);
      if (!wasPlotted) {
        listing.hide();
      }
    }
    return this.updateResultsCount();
  };

  /*
   * Return Search.Listing objects from the search results.
   */
  SearchSearchController.prototype.getListingsFromResults = function() {
    var listings;
    listings = [];
    this.resultsContainer().find('.listing').each(
      (function(_this) {
        return function(i, el) {
          var listing;
          listing = _this.listingForElementOrBuild(el);
          return listings.push(listing);
        };
      })(this)
    );
    return listings;
  };

  /*
   * Initialize or build a Search.Listing object from the DOM element.
   * Handles memoizing by listing ID and swapping the backing DOM element
   * for the leasting from search result refreshes/changes.
   *
   * TODO: Migrate to generating the result HTML elements client-side so we can
   *       avoid this complexity.
   */
  SearchSearchController.prototype.listingForElementOrBuild = function(element) {
    var id, listing;
    id = $(element).attr('data-id');
    if (this.listings[id]) {
      listing = this.listings[id];
    } else {
      listing = SearchListing.forElement(element);
    }
    listing.setElement(element);
    return listing;
  };

  /*
   * Triggers a search request with the current map bounds as the geo constraint
   */
  SearchSearchController.prototype.triggerSearchWithBounds = function() {
    var bounds;
    bounds = this.map.getBoundsArray();
    this.assignFormParams({
      nx: this.formatCoordinate(bounds[0]),
      ny: this.formatCoordinate(bounds[1]),
      sx: this.formatCoordinate(bounds[2]),
      sy: this.formatCoordinate(bounds[3]),
      ignore_search_event: 1
    });
    this.mapTrigger = true;
    return this.triggerSearchAndHandleResults(
      (function(_this) {
        return function() {
          _this.plotListingResultsWithinBounds();
          return _this.assignFormParams({ ignore_search_event: 1 });
        };
      })(this)
    );
  };

  /*
   * Provide a debounced method to trigger the search after a period of constant state
   */
  SearchSearchController.prototype.triggerSearchWithBoundsAfterDelay = _.debounce(function() {
    return this.triggerSearchWithBounds();
  }, 300);

  /*
   * Trigger the search from manipulating the query.
   * Note that the behaviour semantics are different to manually moving the map.
   */
  SearchSearchController.prototype.triggerSearchFromQuery = function(page) {
    var all_categories,
      categories_checkboxes,
      category_inputs,
      category_selects,
      custom_attribute,
      custom_attributes,
      j,
      len,
      price_max,
      ref;
    if (page == null) {
      page = false;
    }

    /*
     * we want to log any new search query
     */
    categories_checkboxes = _.toArray(
      this.container
        .find('input[name="category_ids[]"]:checked, input[data-category-filter]:checked')
        .map(function() {
          return $(this).val();
        })
    );
    category_selects = _.toArray(
      this.container
        .find(
          'select[name="category_ids[]"] option:selected, select[data-category-filter] option:selected'
        )
        .map(function() {
          if ($(this).val()) {
            return $(this).val();
          }
        })
    );
    category_inputs = [];
    this.container.find('input[name="categories_ids[]"]').each(function() {
      var value, values;
      value = $(this).val();
      if (value && value !== '') {
        values = value.split(',');
        return (category_inputs = category_inputs.concat(values));
      }
    });
    all_categories = category_inputs.concat(categories_checkboxes, category_selects);
    if (!page || parseInt($(page).val()) === 1) {
      this.mapTrigger = false;
    }
    price_max = this.container.find('input[name="price[max]"]:checked').length > 0
      ? this.container.find('input[name="price[max]"]:checked').val()
      : $('input[name="price[max]"]').val();
    this.assignFormParams({
      'price[max]': price_max,
      time_from: this.container.find('select[name="time_from"]').val(),
      time_to: this.container.find('select[name="time_to"]').val(),
      sort: this.container.find('select[name="sort"]').val(),
      ignore_search_event: 0,
      category_ids: all_categories.join(','),
      lntype: _.toArray(
        $('input[name="location_types_ids[]"]:checked').map(function() {
          return $(this).val();
        })
      ).join(',')
    });
    custom_attributes = {};
    ref = this.container.find('[data-custom-attribute]');
    for ((j = 0), (len = ref.length); j < len; j++) {
      custom_attribute = ref[j];
      custom_attribute = $(custom_attribute);
      custom_attributes[custom_attribute.data('custom-attribute')] = _.toArray(
        custom_attribute
          .find(
            'input[name="lg_custom_attributes[' +
              custom_attribute.data('custom-attribute') +
              '][]"]:checked'
          )
          .map(function() {
            return $(this).val();
          })
      ).join(',');
    }
    this.assignFormParams({ lg_custom_attributes: custom_attributes });
    this.loader.showWithoutLocker();

    /*
     * Infinite-Ajax-Scroller [ ias ] which we use disables itself when there are no more results
     * we need to reenable it when it is necessary, and only then - otherwise we will get duplicates
     */
    return this.geocodeSearchQuery(
      (function(_this) {
        return function() {
          return _this.triggerSearchAndHandleResults(function() {
            if ($.ias) {
              $.ias('destroy');
              _this.initializeEndlessScrolling();
            }
            _this.movableGoogleMap = $('#search-result-movable-google-map').get(0);
            if (_this.movableGoogleMap != null) {
              new SearchResultsGoogleMapController(
                _this.resultsContainer(),
                _this.movableGoogleMap
              );
            }
            if (_this.map != null) {
              _this.updateMapWithListingResults();
            }
            return _this.updateLinks();
          });
        };
      })(this)
    );
  };

  /*
   * Triggers a search with default UX behaviour and semantics.
   */
  SearchSearchController.prototype.triggerSearchAndHandleResults = function(callback) {
    $(document).trigger('loading:searchResults.nearme');
    this.loader.showWithoutLocker();
    return this.triggerSearchRequest().success(
      (function(_this) {
        return function(html) {
          _this.processingResults = true;
          _this.showResults(html);
          _this.updateUrlForSearchQuery();
          _this.updateLinksForSearchQuery();

          /*
         * This was commented out for UoT purpose, as I couldn't imagine why it is necessary to change user position on page
         * window.scrollTo(0, 0) if !@map
         */
          _this.reinitializePriceSlider();
          _this.loader.hide();
          if (callback) {
            callback();
          }
          _.defer(function() {
            return (_this.processingResults = false);
          });
          return $(document).trigger('load:searchResults.nearme');
        };
      })(this)
    );
  };

  /*
   * Trigger the API request for search
   * Returns a jQuery Promise object which can be bound to execute response semantics.
   */
  SearchSearchController.prototype.triggerSearchRequest = function() {
    var data;
    if (this.currentAjaxRequest) {
      this.currentAjaxRequest.abort();
    }
    data = this.form.serializeArray();
    data.push({ name: 'map_moved', value: this.mapTrigger });
    return (this.currentAjaxRequest = $.ajax({
      url: this.form.attr('action'),
      type: 'GET',
      data: $.param(data)
    }));
  };

  SearchSearchController.prototype.updateListings = function(listings, callback, error_callback) {
    if (error_callback == null) {
      error_callback = function() {};
    }
    return this.triggerListingsRequest(listings)
      .success(function(html) {
        var j, len, listing;
        html = '<div>' + html + '</div>';
        for ((j = 0), (len = listings.length); j < len; j++) {
          listing = listings[j];
          listing.setHtml($('article[data-id="' + listing.id() + '"]', html));
        }
        if (callback) {
          return callback();
        }
      })
      .error(function() {
        if (error_callback) {
          return error_callback();
        }
      });
  };

  SearchSearchController.prototype.updateListing = function(listing, callback) {
    return this.triggerListingsRequest([listing]).success(function(html) {
      listing.setHtml(html);
      if (callback) {
        return callback();
      }
    });
  };

  SearchSearchController.prototype.triggerListingsRequest = function(listings) {
    var listing, listing_ids;
    listing_ids = (function() {
      var j, len, results;
      results = [];
      for ((j = 0), (len = listings.length); j < len; j++) {
        listing = listings[j];
        results.push(listing.id());
      }
      return results;
    })().toString();
    return $.ajax({ url: '/search/show/' + listing_ids + '?v=map', type: 'GET' });
  };

  /*
   * Trigger automatic updating of search results
   */
  SearchSearchController.prototype.fieldChanged = function() {
    return this.triggerSearchFromQuery();
  };

  SearchSearchController.prototype.updateUrlForSearchQuery = function() {
    var params, url;
    url = document.location.href.replace(/\?.*$/, '');
    params = this.getSearchParams();

    /*
     * we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
     * to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
     */
    url = decodeURIComponent('?' + $.param(params));
    return History.replaceState(params, 'Search Results', url);
  };

  SearchSearchController.prototype.updateLinksForSearchQuery = function() {
    var params, url;
    url = document.location.href.replace(/\?.*$/, '');
    params = this.getSearchParams();
    return $('.list-map-toggle a', this.form).each(function() {
      var _url, k, param, view;
      view = $(this).data('view');
      for (k in params) {
        param = params[k];
        if (param['name'] === 'v') {
          param['value'] = view;
        }
      }
      _url = url + '?' + $.param(params) + '&ignore_search_event=1';
      return $(this).attr('href', _url);
    });
  };

  SearchSearchController.prototype.initializeConnectionsTooltip = function() {
    return this.container
      .find('.connections:not(.initialized)')
      .addClass('iinitialized')
      .tooltip({ html: true, placement: 'top' });
  };

  SearchSearchController.prototype.updateLinks = function() {
    if (this.date_range.length > 1) {
      return $('div.locations a:not(.carousel-control)').each(
        (function(_this) {
          return function(index, link) {
            var href;
            if ($(link).closest('.pagination').length > 0) {
              return;
            }
            href = link.href.replace(/\?.*$/, '');
            href +=
              '?start_date=' + _this.date_range[0].value + '&end_date=' + _this.date_range[1].value;
            return (link.href = href);
          };
        })(this)
      );
    }
  };

  SearchSearchController.prototype.initLoadMoreButton = function() {
    return this.container.on(
      'click',
      '.load-more',
      (function(_this) {
        return function(event) {
          var nextPage;
          event.preventDefault();
          nextPage = $(event.target).data('next-page');
          if (nextPage) {
            $("input[name='page']", _this.form).val(nextPage);
            return _this.triggerSearchFromQuery();
          }
        };
      })(this)
    );
  };

  return SearchSearchController;
})(SearchController);

module.exports = SearchSearchController;
