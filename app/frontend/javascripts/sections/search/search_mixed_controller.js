/* global google */
var CustomInputs,
  SearchGeocoder,
  SearchMapMixed,
  SearchMixedController,
  SearchRedoSearchMapControl,
  SearchResultsGoogleMapMarker,
  SearchSearchController,
  urlUtil,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  },
  extend = function(child, parent) {
    for (var key in parent) {
      if (hasProp.call(parent, key))
        child[key] = parent[key];
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

SearchSearchController = require('./search_controller');

urlUtil = require('../../lib/utils/url');

SearchMapMixed = require('./map_mixed');

SearchRedoSearchMapControl = require('./redo_search_map_control');

SearchResultsGoogleMapMarker = require('../../components/search_results_google_map_marker');

CustomInputs = require('../../components/custom_inputs');

SearchGeocoder = require('./geocoder');

SearchMixedController = function(superClass) {
  extend(SearchMixedController, superClass);

  function SearchMixedController(form, container1) {
    var params_category_ids;
    this.container = container1;
    this.reinitializePriceSlider = bind(this.reinitializePriceSlider, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.resultsContainer = function(_this) {
      return function() {
        return _this.container.find('.locations');
      };
    }(this);
    this.hiddenResultsContainer = function(_this) {
      return function() {
        return _this.container.find('.hidden-locations');
      };
    }(this);
    this.list_container = function(_this) {
      return function() {
        return _this.container.find('div[data-list]');
      };
    }(this);
    this.sortField = this.container.find('#sort');
    this.perPageField = this.container.find('#per_page');
    SearchMixedController.__super__.constructor.call(this, form, this.container);
    this.adjustListHeight();
    this.sortValue = this.sortField.find(':selected').val();
    this.perPageValue = this.perPageField.find(':selected').val();
    this.bindLocationsEvents();
    this.initializeCarousel();
    this.initializePriceSlider();
    params_category_ids = urlUtil.getParameterByName('category_ids').split(',');
    this.renderChildCategories(params_category_ids);
    this.autocompleteCategories();
    this.setListingCounter();
  }

  SearchMixedController.prototype.bindEvents = function() {
    SearchMixedController.__super__.bindEvents.apply(this, arguments);
    $(window).resize(
      function(_this) {
        return function() {
          return _this.adjustListHeight();
        };
      }(this)
    );
    this.sortField.on(
      'change',
      function(_this) {
        return function() {
          if (_this.sortValue !== _this.sortField.find(':selected').val()) {
            _this.sortValue = _this.sortField.find(':selected').val();
            return _this.form.submit();
          }
        };
      }(this)
    );
    this.perPageField.on(
      'change',
      function(_this) {
        return function() {
          if (_this.perPageValue !== _this.perPageField.find(':selected').val()) {
            _this.perPageValue = _this.perPageField.find(':selected').val();
            return _this.form.submit();
          }
        };
      }(this)
    );
    if (this.autocompleteEnabled()) {
      $('input.query').keypress(
        function(_this) {
          return function(e) {
            var deferred, query;
            if (e.which === 13) {
              /*
             * if user pressed enter, we will prevent submitting the form and do it manually, when we are ready [ i.e. after geocoding query ]
             */
              _this.submit_form = false;
              query = _this.queryField.val();
              deferred = _this.geocoder.geocodeAddress(query);
              deferred.always(function(results) {
                var result;
                if (results) {
                  result = results.getBestResult();
                }
                _this.clearBoundParams();
                _this.setGeolocatedQuery(query, result);
                _this.submit_form = true;
                return _.defer(function() {
                  return google.maps.event.trigger(_this.autocomplete, 'place_changed');
                });
              });
              return false;
            } else {
              _this.submit_form = false;
              return true;
            }
          };
        }(this)
      );
    }
    this.searchButton.bind(
      'click',
      function(_this) {
        return function() {
          return _this.submit_form = true;
        };
      }(this)
    );
    $(document).on(
      'click',
      '.pagination a',
      function(_this) {
        return function(e) {
          var link, res;
          e.preventDefault();
          link = $(e.target).closest('a');
          _this.loader.show();
          res = /page=(\d+)/gm.exec(link.attr('href'));
          if (res[1]) {
            return _this.triggerSearchFromQuery(res[1]);
          }
        };
      }(this)
    );
    return $(document).on('click', '.list .locations .location .listing', function(e) {
      if (!$(e.target).hasClass('truncated-ellipsis')) {
        if ($(e.target).hasClass('listing')) {
          return window.location.href = $(e.target).find('.reserve-listing a').attr('href');
        } else {
          return window.location.href = $(e.target)
            .parents('.listing')
            .find('.reserve-listing a')
            .attr('href');
        }
      }
    });
  };

  SearchMixedController.prototype.initializeSearchButton = function() {
    this.searchButton = this.form.find('.search-icon');
    if (this.searchButton.length > 0) {
      return this.searchButton.bind(
        'click',
        function(_this) {
          return function() {
            _this.clearBoundParams();
            return _this.form.submit();
          };
        }(this)
      );
    }
  };

  SearchMixedController.prototype.adjustListHeight = function() {
    return this.list_container().height($(window).height() - this.list_container().offset().top);
  };

  SearchMixedController.prototype.initializeMap = function() {
    var mapContainer, resizeMapThrottle;
    mapContainer = this.container.find('#listings_map')[0];
    if (!mapContainer) {
      return;
    }
    this.map = new SearchMapMixed(mapContainer, this);

    /*
     * Add our map viewport search control, which enables/disables searching on map move
     */
    this.redoSearchMapControl = new SearchRedoSearchMapControl({
      enabled: true,
      update_text: $(mapContainer).data('update-text')
    });
    resizeMapThrottle = _.throttle(
      function(_this) {
        return function() {
          return _this.map.resizeToFillViewport();
        };
      }(this),
      200
    );
    $(window).resize(resizeMapThrottle);
    $(window).trigger('resize');
    this.updateMapWithListingResults();
    return this.map.addControl(this.redoSearchMapControl);
  };

  SearchMixedController.prototype.initializeAutocomplete = function() {
    var options, restrictCountries;
    options = {};
    restrictCountries = this.queryField.data('restrict-countries');
    if (restrictCountries && restrictCountries.length > 0) {
      options['componentRestrictions'] = { 'country': restrictCountries };
    }
    this.autocomplete = new google.maps.places.Autocomplete(this.queryField[0], options);
    return google.maps.event.addListener(
      this.autocomplete,
      'place_changed',
      function(_this) {
        return function() {
          var place;
          if (_this.submit_form) {
            _this.loader.show();
            _this.submit_form = false;
            return _this.form.submit();
          } else {
            place = SearchGeocoder.wrapResult(_this.autocomplete.getPlace());
            if (!place.isValid()) {
              place = null;
            }
            return _this.setGeolocatedQuery(_this.queryField.val(), place);
          }
        };
      }(this)
    );
  };

  SearchMixedController.prototype.markerClicked = function(marker) {
    var animate_position, listing, location_container;
    this.processingResults = true;
    listing = this.map.getListingForMarker(marker);
    location_container = this.resultsContainer().find('article[data-id=' + listing.id() + ']');
    if (location_container.length > 0) {
      animate_position = location_container.position().top + this.list_container().offset().top +
        this.list_container().find('.filters').height() -
        55;
      return this.list_container().animate(
        { scrollTop: animate_position },
        function(_this) {
          return function() {
            _this.unmarkAllLocations();
            location_container.addClass('active');
            return _this.processingResults = false;
          };
        }(this)
      );
    }
  };

  SearchMixedController.prototype.getListingsFromResults = function() {
    var listings;
    listings = [];
    this.resultsContainer().find('.location-marker').each(
      function(_this) {
        return function(i, el) {
          var listing;
          listing = _this.listingForElementOrBuild(el);
          return listings.push(listing);
        };
      }(this)
    );
    return listings;
  };

  SearchMixedController.prototype.initializeEndlessScrolling = function() {
    return this.list_container().scrollTop(0);
  };

  SearchMixedController.prototype.unmarkAllLocations = function() {
    return this.resultsContainer().find('article').removeClass('active');
  };

  /*
   * Trigger the API request for search
   * Returns a jQuery Promise object which can be bound to execute response semantics.
   */
  SearchMixedController.prototype.triggerSearchRequest = function() {
    var data;
    if (this.currentAjaxRequest) {
      this.currentAjaxRequest.abort();
    }
    data = this.form.add('.list .sort :input').serializeArray();
    data.push({ 'name': 'map_moved', 'value': this.mapTrigger });
    return this.currentAjaxRequest = $.ajax({
      url: this.form.attr('action'),
      type: 'GET',
      data: $.param(data)
    });
  };

  /*
   * Trigger the search from manipulating the query.
   * Note that the behaviour semantics are different to manually moving the map.
   */
  SearchMixedController.prototype.triggerSearchFromQuery = function(page) {
    if (page == null) {
      page = false;
    }

    /*
     * assign filter values
     */
    this.assignFormParams({
      lntype: _.toArray(
        this.container.find('input[name="location_types_ids[]"]:checked').map(function() {
          return $(this).val();
        })
      ).join(','),
      lgpricing: _.toArray(
        this.container.find('input[name="listing_pricing[]"]:checked').map(function() {
          return $(this).val();
        })
      ).join(','),
      sort: this.container.find('#sort').val(),
      per_page: this.container.find('#per_page').val(),
      loc: this.form.find('input#search').val().replace(', United States', ''),
      page: page || 1,
      start_date: this.container.find('input[name="fake_start_date"]').val(),
      end_date: this.container.find('input[name="fake_end_date"]').val(),
      avilability_end: this.container.find('input[availability_dates_end]').val(),
      avilability_start: this.container.find('input[availability_dates_start]').val()
    });
    return SearchMixedController.__super__.triggerSearchFromQuery.apply(this, arguments);
  };

  SearchMixedController.prototype.renderChildCategories = function(params_category_ids) {
    var category_ids, container;
    if (params_category_ids == null) {
      params_category_ids = [];
    }
    category_ids = _.toArray(
      this.container.find('input[name="category_ids[]"]:checked').map(function() {
        return $(this).val();
      })
    );
    Array.prototype.push.apply(category_ids, params_category_ids);
    category_ids = category_ids.join(',');
    this.container.find('#categories-children').html('');
    container = this.container;
    return $.ajax({
      url: '/search/categories',
      type: 'GET',
      data: { category_ids: category_ids },
      success: function(_this) {
        return function(data) {
          var subcategories_parents;
          _this.container.find('#categories-children').hide().html(data);
          subcategories_parents = [];
          _this.container.find('.categories-children').html('');
          _this.container
            .find('#categories-children')
            .find('.search-mixed-filter')
            .each(function(index, elem) {
              var category_id, filter, new_category, newdiv, subcat;
              subcat = $(elem).clone();
              category_id = parseInt(subcat.attr('data-category-id'));
              filter = container
                .find('input[name="category_ids[]"][value="' + category_id + '"]')
                .closest('.search-mixed-filter');
              new_category = subcategories_parents.indexOf(filter.get(0)) === -1;
              if (new_category) {
                newdiv = $("<div class='categories-children'></div>");
                newdiv.append(subcat);
              }
              if (filter.next().hasClass('categories-children')) {
                if (new_category) {
                  filter.next().html(newdiv.html());
                } else {
                  filter.next().append(subcat);
                }
              } else {
                filter.after(newdiv);
              }
              return subcategories_parents.push(filter.get(0));
            });
          _this.container.find('#categories-children').html('');
          return new CustomInputs();
        };
      }(this)
    });
  };

  SearchMixedController.prototype.updateResultsCount = function() {
    var count, inflection;
    count = parseInt(this.hiddenResultsContainer().find('input#result_count').val());
    inflection = 'result';
    if (count !== 1) {
      inflection += 's';
    }
    this.resultsCountContainer.html('<span>' + count + '</span> ' + inflection);
    return this.initializeEndlessScrolling();
  };

  SearchMixedController.prototype.updateMapWithListingResults = function() {
    var bounds, deferred, j, lat, len, listing, listings, lng, map_center, query;
    this.map.resetMapMarkers();
    listings = this.getListingsFromResults();
    if (listings != null && listings.length > 0) {
      this.map.plotListings(listings);

      /*
       * Only show bounds of new results
       */
      bounds = new google.maps.LatLngBounds();
      for (j = 0, len = listings.length; j < len; j++) {
        listing = listings[j];
        bounds.extend(listing.latLng());
      }
      lat = this.form.find('input[name=lat]').val();
      lng = this.form.find('input[name=lng]').val();
      if (lat.length && lng.length) {
        bounds.extend(new google.maps.LatLng(
          this.form.find('input[name=lat]').val(),
          this.form.find('input[name=lng]').val()
        ));
      }
      _.defer(
        function(_this) {
          return function() {
            return _this.map.fitBounds(bounds);
          };
        }(this)
      );
      this.map.show();

      /*
       * In case the map is hidden
       */
      return this.map.resizeToFillViewport();
    } else {
      if (this.form.find('input[name=lat]').val() !== '') {
        map_center = new google.maps.LatLng(
          this.form.find('input[name=lat]').val(),
          this.form.find('input[name=lng]').val()
        );
        _.defer(
          function(_this) {
            return function() {
              return _this.map.setCenter(map_center);
            };
          }(this)
        );
        this.map.show();

        /*
         * In case the map is hidden
         */
        return this.map.resizeToFillViewport();
      } else {
        /*
         * no results found, try to set map center on searched city
         */
        query = this.queryField.val();
        deferred = this.geocoder.geocodeAddress(query);
        return deferred.always(
          function(_this) {
            return function(results) {
              var result;
              if (results) {
                result = results.getBestResult();
                _this.map.setCenter(new google.maps.LatLng(result.lat(), result.lng()));
                _this.map.setZoom(11);
                _this.map.show();

                /*
               * In case the map is hidden
               */
                return _this.map.resizeToFillViewport();
              }
            };
          }(this)
        );
      }
    }
  };

  /*
   * Within the current map display, plot the listings from the current results. Remove listings
   * that aren't within the current map bounds from the results.
   */
  SearchMixedController.prototype.plotListingResultsWithinBounds = function() {
    this.map.resetMapMarkers();
    return SearchMixedController.__super__.plotListingResultsWithinBounds.apply(this, arguments);
  };

  SearchMixedController.prototype.showResults = function(html) {
    this.resultsContainer().replaceWith(html);
    this.updateResultsCount();
    this.list_container().scrollTop(0);
    this.bindLocationsEvents();
    return this.setListingCounter();
  };

  /*
   * Trigger automatic updating of search results
   */
  SearchMixedController.prototype.fieldChanged = function() {
    this.renderChildCategories();
    return this.triggerSearchFromQuery();
  };

  SearchMixedController.prototype.autocompleteCategories = function() {
    var self;
    self = this;
    if (this.container.find('input[data-category-autocomplete]').length > 0) {
      return $.each(this.container.find('input[data-category-autocomplete]'), function(
        index,
        select
      ) {
        return $(select).select2({
          multiple: true,
          initSelection: function(element, callback) {
            var url;
            url = $(select).attr('data-api-category-path');
            return $.getJSON(
              url,
              { init_selection: 'true', ids: $(select).attr('data-selected-categories') },
              function(data) {
                return callback(data);
              }
            );
          },
          ajax: {
            url: $(select).attr('data-api-category-path'),
            datatype: 'json',
            data: function(term, page) {
              return { per_page: 50, page: page, q: { name_cont: term } };
            },
            results: function(data) {
              return { results: data };
            }
          },
          formatResult: function(category) {
            return category.translated_name;
          },
          formatSelection: function(category) {
            return category.translated_name;
          }
        }).on('change', function() {
          return self.fieldChanged();
        }).select2('val', $(select).attr('data-selected-categories'));
      });
    }
  };

  SearchMixedController.prototype.updateUrlForSearchQuery = function() {
    var filtered_params, k, param, params, url;
    url = document.location.href.replace(/\?.*$/, '');
    params = this.getSearchParams();
    filtered_params = [];
    for (k in params) {
      param = params[k];
      if ($.inArray(param['name'], [ 'ignore_search_event', 'country', 'v' ]) < 0) {
        filtered_params.push({ name: param['name'], value: param['value'] });
      }
    }
    if (this.sortValue !== 'relevance') {
      filtered_params.push({ name: 'sort', value: this.sortValue });
    }

    /*
     * we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
     * to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
     */
    url = decodeURIComponent('?' + $.param(filtered_params));
    return History.replaceState(params, this.container.find('input[name=meta_title]').val(), url);
  };

  SearchMixedController.prototype.bindLocationsEvents = function() {
    this.resultsContainer().find('article.location').on(
      'mouseleave',
      function(_this) {
        return function(event) {
          var location, location_id, marker;
          location = $(event.target).closest('article.location');
          _this.unmarkAllLocations();
          location_id = location.data('id');
          marker = _this.map.markers[location_id];
          if (marker) {
            marker.setIcon(SearchResultsGoogleMapMarker.getMarkerOptions()['default'].image);
            return marker.setZIndex(google.maps.Marker.MAX_ZINDEX);
          }
        };
      }(this)
    );
    return this.resultsContainer().find('article.location').on(
      'mouseenter',
      function(_this) {
        return function(event) {
          var location, location_id, marker;
          location = $(event.target).closest('article.location');
          _this.unmarkAllLocations();
          location.addClass('active');
          location_id = location.data('id');
          marker = _this.map.markers[location_id];
          if (marker) {
            marker.setIcon(SearchResultsGoogleMapMarker.getMarkerOptions().hover.image);
            return marker.setZIndex(google.maps.Marker.MAX_ZINDEX + 1);
          }
        };
      }(this)
    );
  };

  SearchMixedController.prototype.clearBoundParams = function() {
    return this.assignFormParams({ page: 1, nx: '', ny: '', sx: '', sy: '', lat: '', lng: '' });
  };

  /*
   * Triggers a search request with the current map bounds as the geo constraint
   */
  SearchMixedController.prototype.triggerSearchWithBounds = function() {
    var all_categories,
      bounds,
      categories_checkboxes,
      categories_selects,
      custom_attribute,
      custom_attributes,
      j,
      len,
      price_max,
      ref;
    bounds = this.map.getBoundsArray();
    categories_checkboxes = _.toArray(
      this.container.find('input[name="category_ids[]"]:checked').map(function() {
        return $(this).val();
      })
    );
    categories_selects = [];
    this.container.find('input[name="categories_ids[]"]').each(function() {
      var value, values;
      value = $(this).val();
      if (value && value !== '') {
        values = value.split(',');
        return categories_selects = categories_selects.concat(values);
      }
    });
    all_categories = categories_selects.concat(categories_checkboxes);
    price_max = this.container.find('input[name="price[max]"]:checked').length > 0
      ? this.container.find('input[name="price[max]"]:checked').val()
      : $('input[name="price[max]"]').val();
    this.assignFormParams({
      nx: this.formatCoordinate(bounds[0]),
      ny: this.formatCoordinate(bounds[1]),
      sx: this.formatCoordinate(bounds[2]),
      sy: this.formatCoordinate(bounds[3]),
      ignore_search_event: 1,
      page: 1,
      category_ids: all_categories.join(','),
      'price[max]': price_max,
      time_from: this.container.find('select[name="time_from"]').val(),
      time_to: this.container.find('select[name="time_to"]').val(),
      sort: this.container.find('select[name="sort"]').val(),
      lntype: _.toArray(
        $('input[name="location_types_ids[]"]:checked').map(function() {
          return $(this).val();
        })
      ).join(',')
    });
    custom_attributes = {};
    ref = this.container.find('div[data-custom-attribute]');
    for (j = 0, len = ref.length; j < len; j++) {
      custom_attribute = ref[j];
      custom_attribute = $(custom_attribute);
      custom_attributes[custom_attribute.data('custom-attribute')] = _.toArray(
        custom_attribute
          .find(
            'input[name="lg_custom_attributes[' + custom_attribute.data('custom-attribute') +
              '][]"]:checked'
          )
          .map(function() {
            return $(this).val();
          })
      ).join(',');
    }
    this.assignFormParams({ lg_custom_attributes: custom_attributes });
    this.mapTrigger = true;
    return this.triggerSearchAndHandleResults(
      function(_this) {
        return function() {
          _this.plotListingResultsWithinBounds();
          return _this.assignFormParams({ ignore_search_event: 1 });
        };
      }(this)
    );
  };

  SearchMixedController.prototype.initializeCarousel = function() {
    return $('.carousel').carousel({ interval: 7000 });
  };

  SearchMixedController.prototype.reinitializePriceSlider = function() {
    $('#price-slider').remove();
    $('.price-slider-container').append('<div id="price-slider"></div>');
    return SearchMixedController.__super__.reinitializePriceSlider.apply(this, arguments);
  };

  SearchMixedController.prototype.setListingCounter = function() {
    var counter, i, j, len, offset, ref, results1;
    offset = parseInt(this.container.find('.search-pagination').data('offset'));
    ref = this.container.find('.location-counter');
    results1 = [];
    for (i = j = 0, len = ref.length; j < len; i = ++j) {
      counter = ref[i];
      results1.push($(counter).text(i + offset));
    }
    return results1;
  };

  return SearchMixedController;
}(SearchSearchController);

module.exports = SearchMixedController;
