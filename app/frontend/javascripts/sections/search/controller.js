/* global google */
var Geocoder,
  PriceRange,
  SearchController,
  SearchDatepickers,
  urlUtil,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

SearchDatepickers = require('./datepickers');

Geocoder = require('./geocoder');

urlUtil = require('../../lib/utils/url');

PriceRange = require('../../components/price_range');

require('nouislider/distribute/jquery.nouislider.all');

/*
 * Base search controller
 * Extended by Search.HomeController and Search.SearchController
 */
SearchController = function() {
  function SearchController(form, container) {
    this.form = form;
    this.container = container;
    this.initializePriceSlider = bind(this.initializePriceSlider, this);
    this.unfilteredPrice = 0;
    this.initializeFields();
    this.initializeGeolocateButton();
    this.initializeSearchButton();
    if (this.autocompleteEnabled()) {
      this.initializeAutocomplete();
    }
    this.initializeGeocoder();
    new SearchDatepickers($('body'));
  }

  SearchController.prototype.initializeAutocomplete = function(queryField) {
    var autocomplete, options, restrictCountries;
    queryField || (queryField = this.queryField);
    options = {};
    restrictCountries = queryField.data('restrict-countries');
    if (restrictCountries && restrictCountries.length > 0) {
      options['componentRestrictions'] = { 'country': restrictCountries };
    }
    autocomplete = new google.maps.places.Autocomplete(queryField[0], options);
    this.submit_form = false;
    return google.maps.event.addListener(
      autocomplete,
      'place_changed',
      function(_this) {
        return function() {
          var place;
          place = Geocoder.wrapResult(autocomplete.getPlace());
          if (!place.isValid()) {
            place = null;
          }
          _this.setGeolocatedQuery(queryField.val(), place);
          _this.fieldChanged('query', queryField.val());
          if (_this.submit_form) {
            return _this.form.submit();
          }
        };
      }(this)
    );
  };

  SearchController.prototype.initializeGeocoder = function() {
    return this.geocoder = new Geocoder();
  };

  /*
   * Initialize all filters for the search form
   */
  SearchController.prototype.initializeFields = function() {
    this.priceRange = new PriceRange(this.form.find('.price-range'), 300, this);
    return this.initializeQueryField();
  };

  SearchController.prototype.fieldChanged = function() {};

  SearchController.prototype.initializeQueryField = function() {
    this.queryField = this.form.find('input[name="loc"]');
    this.keywordField = this.form.find('input[name="query"]');
    urlUtil.getParameterByName('loc');
    this.queryField.bind(
      'change',
      function(_this) {
        return function() {
          return _this.fieldChanged('query', _this.queryField.val());
        };
      }(this)
    );
    this.keywordField.bind(
      'change',
      function(_this) {
        return function() {
          return _this.fieldChanged('query', _this.keywordField.val());
        };
      }(this)
    );
    this.queryField.bind(
      'focus',
      function(_this) {
        return function() {
          if (_this.queryField.val() === _this.queryField.data('placeholder')) {
            _this.queryField.val('');
          }
          return true;
        };
      }(this)
    );
    return this.queryField.bind(
      'blur',
      function(_this) {
        return function() {
          if (_this.queryField.val().length < 1 && _this.queryField.data('placeholder') != null) {
            _.defer(function() {
              return _this.queryField.val(_this.queryField.data('placeholder'));
            });
          }
          return true;
        };
      }(this)
    );
    /*
     * TODO: Trigger fieldChanged on keypress after a few seconds timeout?
     */
  };

  SearchController.prototype.initializeGeolocateButton = function() {
    this.geolocateButton = this.form.find('.geolocation');
    return this.geolocateButton.addClass('active').bind(
      'click',
      function(_this) {
        return function() {
          return _this.geolocateMe();
        };
      }(this)
    );
  };

  SearchController.prototype.initializeSearchButton = function() {
    this.searchButton = this.form.find('.search-icon');
    if (this.searchButton.length > 0) {
      return this.searchButton.bind(
        'click',
        function(_this) {
          return function() {
            return _this.form.submit();
          };
        }(this)
      );
    }
  };

  SearchController.prototype.geolocateMe = function() {
    return this.determineUserLocation();
  };

  SearchController.prototype.determineUserLocation = function() {
    if (!Modernizr.geolocation) {
      return;
    }
    this.form.find('.geolocation .ico-crosshairs').hide();
    this.form.find('.geolocation .geo-loading').show();
    return navigator.geolocation.getCurrentPosition(
      function(_this) {
        return function(position) {
          var deferred;
          deferred = _this.geocoder.reverseGeocodeLatLng(
            position.coords.latitude,
            position.coords.longitude
          );
          return deferred.done(function(resultset) {
            var cityAndStateAddress, existingVal;
            cityAndStateAddress = resultset.getBestResult().cityAndStateAddress();
            existingVal = _this.queryField.val();
            if (cityAndStateAddress !== existingVal) {
              /*
             * two cached variables are used in Search.HomeController in form.submit handler
             */
              _this.cached_geolocate_me_result_set = resultset.getBestResult();
              _this.cached_geolocate_me_city_address = cityAndStateAddress;
              _this.queryField.val(cityAndStateAddress).data('placeholder', cityAndStateAddress);
              _this.fieldChanged('query', _this.queryField.val());
              _this.setGeolocatedQuery(
                _this.queryField.val(),
                _this.cached_geolocate_me_result_set
              );
              _this.form.find('.geolocation .ico-crosshairs').show();
              return _this.form.find('.geolocation .geo-loading').hide();
            }
          });
        };
      }(this),
      function(_this) {
        return function(error) {
          if (error.code === error.PERMISSION_DENIED) {
            _this.form.find('.geolocation .ico-crosshairs').show();
            _this.form.find('.geolocation .geo-loading').hide();
          }
        };
      }(this)
    );
  };

  /*
   * Is the given query currently geolocated by the search
   */
  SearchController.prototype.isQueryGeolocated = function(query) {
    /*
     * Note that we don't check the presence of the gelocation result. This is because the result can be null,
     * which means geolocation was attempted but failed, so we don't try again.
     */
    return this.currentGeolocationResultQuery === query;
  };

  /*
   * Set the active geolocated query. Triggers updating of the form params.
   */
  SearchController.prototype.setGeolocatedQuery = function(query, result) {
    this.currentGeolocationResultQuery = query;
    this.currentGeolocationResult = result;
    return this.assignFormParams(this.searchParamsFromGeolocationResult(result));
  };

  /*
   * Returns special search params based on a geolocation result (Search.Geolocator.Result), or no result.
   */
  SearchController.prototype.searchParamsFromGeolocationResult = function(result) {
    var boundingBox, params;
    params = {
      lat: null,
      lng: null,
      nx: null,
      ny: null,
      sx: null,
      sy: null,
      country: null,
      state: null,
      city: null,
      suburb: null,
      street: null,
      postcode: null
    };
    if (result) {
      boundingBox = result.boundingBox();
      params['lat'] = this.formatCoordinate(result.lat());
      params['lng'] = this.formatCoordinate(result.lng());
      params['sx'] = this.formatCoordinate(boundingBox[0]);
      params['sy'] = this.formatCoordinate(boundingBox[1]);
      params['nx'] = this.formatCoordinate(boundingBox[2]);
      params['ny'] = this.formatCoordinate(boundingBox[3]);
      params['country'] = result.country();
      params['state'] = result.state();
      params['city'] = result.city();
      params['suburb'] = result.suburb();
      params['street'] = result.street();
      params['postcode'] = result.postcode();
    }
    params['loc'] = this.buildSeoFriendlyQuery(result);
    return params;
  };

  SearchController.prototype.buildSeoFriendlyQuery = function(result) {
    var query, stateRegexp;
    if (result) {
      query = $.trim(result.formattedAddress().replace(', United States', ''));
      if (result.country() && result.country() === 'United States') {
        stateRegexp = new RegExp(result.state() + '$', 'i');
        if (result.state() && query.match(stateRegexp)) {
          query = query.replace(stateRegexp, result.stateShort());
        }
      }
      return query;
    } else {
      query = this.form.find("input[name='loc']").val() || '';
      return $.trim(query.replace(', United States', ''));
    }
  };

  SearchController.prototype.formatCoordinate = function(coord) {
    if (coord != null) {
      return coord.toFixed(5);
    }
  };

  SearchController.prototype.assignFormParams = function(paramsHash) {
    /*
     * Write params to search form
     */
    var field, key, results1, val, value;
    results1 = [];
    for (field in paramsHash) {
      value = paramsHash[field];
      if (field === 'lg_custom_attributes') {
        results1.push(
          function() {
            var results2;
            results2 = [];
            for (key in value) {
              val = value[key];
              results2.push(
                this.form.parent().find('input[name="lg_custom_attributes[' + key + ']"]').val(val)
              );
            }
            return results2;
          }.call(this)
        );
      } else {
        results1.push(this.form.parent().find("input[name='" + field + "']").val(value));
      }
    }
    return results1;
  };

  SearchController.prototype.getSearchParams = function() {
    var form_params, k, param, params;
    form_params = this.form.serializeArray();
    form_params = this.replaceWithData(form_params);

    /*
     * don't polute url if this is unnecessary - ignore empty values and page
     */
    params = [];
    for (k in form_params) {
      param = form_params[k];
      if (param['name'] !== 'page' && param['value'] !== '') {
        params.push(param);
      }
    }
    return params;
  };

  /*
   * Geocde the search query and assign it as the geocoded result
   */
  SearchController.prototype.geocodeSearchQuery = function(callback) {
    var deferred, query;
    query = this.queryField.val();

    /*
     * if query field is empty, do not attempt to run geolocation
     */
    if (!query) {
      return callback();
    }

    /*
     * If the query has already been geolocated we can just search immediately
     */
    if (this.isQueryGeolocated(query) || this.mapTrigger) {
      return callback();
    }

    /*
     * Otherwise we need to geolocate the query and assign it before searching
     */
    deferred = this.geocoder.geocodeAddress(query);
    return deferred.always(
      function(_this) {
        return function(results) {
          var result;
          if (results) {
            result = results.getBestResult();
          }
          _this.setGeolocatedQuery(query, result);
          return callback();
        };
      }(this)
    );
  };

  /*
   * If element has data-value attribute it will replace native value of the element
   * Used for date range picker
   */
  SearchController.prototype.replaceWithData = function(formParams) {
    var element, k, param, params;
    params = [];
    for (k in formParams) {
      param = formParams[k];
      element = this.form.find("input[name='" + param['name'] + "']");
      if (element.data('value')) {
        params.push({ name: param['name'], value: element.data('value') });
      } else {
        params.push(param);
      }
    }
    return params;
  };

  SearchController.prototype.autocompleteEnabled = function() {
    return this.queryField.length && this.queryField.data('disable-autocomplete') === void 0;
  };

  SearchController.prototype.responsiveCategoryTree = function() {
    if ($('#category-tree').length > 0) {
      $(window).resize(
        function(_this) {
          return function() {
            return _this.categoryTreeInit(true);
          };
        }(this)
      );
      return this.categoryTreeInit(false);
    }
  };

  SearchController.prototype.categoryTreeInit = function(windowResized) {
    var i, len, ref, target;
    if (!windowResized) {
      $('.nav-categories  > ul > .categories-list > .nav-item ').find('.categories-list').hide();
    }
    ref = $(".nav-item input[type='checkbox']:checked");
    for (i = 0, len = ref.length; i < len; i++) {
      target = ref[i];
      $(target).parents('.nav-item:first').find('ul.categories-list:first').show();
    }
    $('.nav-heading input').parents('.nav-heading').next().show();
    $('.nav-heading input').unbind('change');
    return $(".nav-item input[type='checkbox']").on('change', function(event) {
      if ($(event.target).prop('checked')) {
        return $(event.target).closest('label').next().show();
      } else {
        $(event.target).closest('li').find('.categories-list').hide();
        return $(event.target).closest('label').next().find('input:checked').prop('checked', false);
      }
    });
  };

  SearchController.prototype.updatePriceSlider = function() {
    var end_value, start_value;
    start_value = $('.search-max-price:first').attr('data-min-price');
    end_value = $('.search-max-price:first').attr('data-max-price');
    return $('#price-slider').val([ start_value, end_value ]);
  };

  SearchController.prototype.reinitializePriceSlider = function() {
    if ($('#price-slider').length > 0) {
      return this.initializePriceSlider();
    }
  };

  SearchController.prototype.initializePriceSlider = function() {
    var elem, start_val, val;
    elem = $('#price-slider');
    if (elem.length > 0) {
      val = parseInt($("input[name='price[max]']").val());
      if (isNaN(val) || val === 0) {
        val = parseInt($('.search-max-price:first').attr('data-max-price'));
      }
      start_val = parseInt($("input[name='price[min]']").val());
      if (isNaN(start_val)) {
        start_val = parseInt($('.search-max-price:first').attr('data-min-price'));
      }
      if (val > this.unfilteredPrice) {
        this.unfilteredPrice = val;
      }
      if (!(start_val >= 0 && val >= 0)) {
        start_val = val = 0;
      }
      elem.noUiSlider({
        start: [ start_val, val ],
        behaviour: 'drag',
        connect: true,
        range: { min: 0, max: this.unfilteredPrice }
      });
      elem.on(
        'change',
        function(_this) {
          return function() {
            $('.search-max-price:first').attr('data-max-price', elem.val()[1]);
            _this.assignFormParams({ 'price[min]': elem.val()[0], 'price[max]': elem.val()[1] });
            return _this.form.submit();
          };
        }(this)
      );
      elem.Link('upper').to('-inline-<div class="slider-tooltip"></div>', function(value) {
        return $(this).html('<strong>$' + parseInt(value) + ' </strong>');
      });
      return elem.Link('lower').to('-inline-<div class="slider-tooltip"></div>', function(value) {
        return $(this).html('<strong>$' + parseInt(value) + ' </strong>');
      });
    }
  };

  return SearchController;
}();

module.exports = SearchController;
