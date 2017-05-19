var SearchController,
  SearchProductsSearchController,
  SearchScreenLockLoader,
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

SearchController = require('./controller');

urlUtil = require('../../lib/utils/url');

SearchScreenLockLoader = require('./screen_lock_loader');

window.IASCallbacks = require('exports?IASCallbacks!../../vendor/jquery-ias/callbacks');

require('../../vendor/jquery-ias/jquery-ias');

SearchProductsSearchController = function(superClass) {
  extend(SearchProductsSearchController, superClass);

  function SearchProductsSearchController(form, container) {
    this.form = form;
    this.container = container;
    this.resultsContainer = bind(this.resultsContainer, this);
    this.redirectIfNecessary();
    this.loader = new SearchScreenLockLoader(
      function(_this) {
        return function() {
          return _this.container.find('.loading');
        };
      }(this)
    );
    this.perPageField = this.container.find('select#per_page');
    this.filters_container = $('div[data-search-filters-container]');
    this.unfilteredPrice = 0;
    this.bindEvents();
    this.performEndlessScrolling = this.form.data('endless-scrolling');
    this.initializeEndlessScrolling();
    this.reinitializeEndlessScrolling = false;
    this.perPageValue = this.perPageField.find(':selected').val();
    this.submitFormWithoutAjax = false;
    this.responsiveCategoryTree();
    this.initializePriceSlider();
    this.autocompleteCategories();
  }

  SearchProductsSearchController.prototype.resultsContainer = function() {
    return this.container.find('#results');
  };

  SearchProductsSearchController.prototype.bindEvents = function() {
    this.filters_container.on(
      'click',
      'input[type=checkbox]:not(.nav-heading > label > input)',
      function(_this) {
        return function() {
          return _this.triggerSearchFromQuery();
        };
      }(this)
    );
    $(document).on(
      'change',
      '.search-attribute-filter select',
      function(_this) {
        return function() {
          _this.perPageValue = _this.perPageField.find(':selected').val();
          return _this.triggerSearchFromQuery();
        };
      }(this)
    );
    this.form.bind(
      'submit',
      function(_this) {
        return function(event) {
          if (_this.submitFormWithoutAjax === false) {
            event.preventDefault();
            return _this.triggerSearchFromQuery();
          }
        };
      }(this)
    );
    this.searchField = this.form.find('#search');
    this.searchField.on(
      'focus',
      function(_this) {
        return function() {
          return $(_this.form).addClass('query-active');
        };
      }(this)
    );
    this.searchField.on(
      'blur',
      function(_this) {
        return function() {
          return $(_this.form).removeClass('query-active');
        };
      }(this)
    );
    this.searchButton = this.form.find('.search-icon');
    if (this.searchButton.length > 0) {
      this.searchButton.bind(
        'click',
        function(_this) {
          return function() {
            return _this.form.submit();
          };
        }(this)
      );
    }
    $(document).on(
      'click',
      '.pagination a',
      function(_this) {
        return function(e) {
          var link, page_regexp;
          e.preventDefault();
          link = $(e.target);
          if (link.attr('href') === void 0) {
            link = link.parents('a');
          }
          page_regexp = /page=(\d+)/gm;
          _this.loader.show();
          return _this.triggerSearchFromQuery(page_regexp.exec(link.attr('href'))[1]);
        };
      }(this)
    );
    return $(document).on(
      'click',
      'a.clear-filters',
      function(_this) {
        return function(e) {
          e.preventDefault();
          _this.submitFormWithoutAjax = true;
          _this.assignFormParams();
          return _this.form.submit();
        };
      }(this)
    );
  };

  SearchProductsSearchController.prototype.rebindForm = function() {
    this.container.find('select').select2({ allowClear: true });
    this.form = $('#search_form');
    this.performEndlessScrolling = this.form.data('endless-scrolling');
    this.form.bind(
      'submit',
      function(_this) {
        return function(event) {
          if (_this.submitFormWithoutAjax === false) {
            event.preventDefault();
            return _this.triggerSearchFromQuery();
          }
        };
      }(this)
    );
    this.searchField = this.form.find('#search');
    this.searchField.on(
      'focus',
      function(_this) {
        return function() {
          return $(_this.form).addClass('query-active');
        };
      }(this)
    );
    this.searchField.on(
      'blur',
      function(_this) {
        return function() {
          return $(_this.form).removeClass('query-active');
        };
      }(this)
    );
    this.searchButton = this.form.find('.search-icon');
    if (this.searchButton.length > 0) {
      this.searchButton.bind(
        'click',
        function(_this) {
          return function() {
            return _this.form.submit();
          };
        }(this)
      );
    }
    return $(document).on(
      'click',
      'a.clear-filters',
      function(_this) {
        return function(e) {
          e.preventDefault();
          _this.submitFormWithoutAjax = true;
          _this.assignFormParams();
          return _this.form.submit();
        };
      }(this)
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
  SearchProductsSearchController.prototype.redirectIfNecessary = function() {
    var k, param, ref, results;
    if (History.getState && !window.history.replaceState) {
      ref = History.getState().data;
      results = [];
      for (k in ref) {
        param = ref[k];
        if (param.name === 'loc') {
          if (param.value !== urlUtil.getParameterByName('loc')) {
            results.push(document.location = History.getState().url);
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

  SearchProductsSearchController.prototype.initializeEndlessScrolling = function() {
    var ias;
    if (this.performEndlessScrolling) {
      $('#results').scrollTop(0);
      ias = jQuery.ias({
        container: '#results',
        item: '.product',
        pagination: '.pagination',
        next: '.next_page',
        triggerPageThreshold: 99,
        history: false,
        thresholdMargin: -90,
        loader: '<div class="row-fluid span12"><h1><img src="' +
          $('img[alt=Spinner]').eq(0).attr('src') +
          '"><span>Loading More Results</span></h1></div>',
        onRenderComplete: function() {
          /*
           * when there are no more resuls, add special div element which tells us, that we need to reinitialize ias - it disables itself on the last page...
           */
          if (!$('#results .pagination .next_page').attr('href')) {
            return $('#results').append('<div id="reinitialize"></div>');
          }
        }
      });
      return ias.on('rendered', function(items) {
        return $(document).trigger('rendered-search:ias.nearme', [ items ]);
      });
    }
  };

  SearchProductsSearchController.prototype.showResults = function(html) {
    this.resultsContainer().replaceWith(html);
    if (this.performEndlessScrolling) {
      return $('.pagination').hide();
    }
  };

  SearchProductsSearchController.prototype.updateResultsCount = function() {
    var count, inflection;
    count = this.resultsContainer().find('.listing:not(.hidden)').length;
    inflection = 'result';
    if (count !== 1) {
      inflection += 's';
    }
    return this.resultsCountContainer.html(count + ' ' + inflection);
  };

  /*
   * Return Search.Listing objects from the search results.
   */
  SearchProductsSearchController.prototype.getListingsFromResults = function() {
    var listings;
    listings = [];
    this.resultsContainer().find('.listing').each(
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

  /*
   * Trigger the search from manipulating the query.
   * Note that the behaviour semantics are different to manually moving the map.
   */
  SearchProductsSearchController.prototype.triggerSearchFromQuery = function() {
    var category_ids;
    category_ids = _.toArray(
      this.container.find('input[name="category_ids[]"]:checked').map(function() {
        return $(this).val();
      })
    );
    this.container.find('input[data-category-autocomplete]').each(function() {
      return category_ids = category_ids.concat($(this).val().split(','));
    });

    /*
     * we want to log any new search query
     */
    this.assignFormParams({
      ignore_search_event: 0,
      per_page: this.container.find('select#per_page').val(),
      category_ids: category_ids.join(','),
      loc: this.form.find('input#search').val(),
      page: 1
    });
    this.loader.showWithoutLocker();

    /*
     * Infinite-Ajax-Scroller [ ias ] which we use disables itself when there are no more results
     * we need to reenable it when it is necessary, and only then - otherwise we will get duplicates
     */
    if ($('#reinitialize').length > 0) {
      this.initializeEndlessScrolling();
    }
    return this.triggerSearchAndHandleResults();
  };

  /*
   * Triggers a search with default UX behaviour and semantics.
   */
  SearchProductsSearchController.prototype.triggerSearchAndHandleResults = function(callback) {
    this.loader.showWithoutLocker();
    return this.triggerSearchRequest().success(
      function(_this) {
        return function(html) {
          _this.processingResults = true;
          _this.showResults(html);
          _this.updateUrlForSearchQuery();
          _this.updateLinksForSearchQuery();
          window.scrollTo(0, 0);
          _this.rebindForm();
          _this.updatePriceSlider();
          _this.loader.hide();
          if (callback) {
            callback();
          }
          return _.defer(function() {
            return _this.processingResults = false;
          });
        };
      }(this)
    );
  };

  /*
   * Trigger the API request for search
   * Returns a jQuery Promise object which can be bound to execute response semantics.
   */
  SearchProductsSearchController.prototype.triggerSearchRequest = function() {
    if (this.currentAjaxRequest) {
      this.currentAjaxRequest.abort();
    }
    return this.currentAjaxRequest = $.ajax({
      url: this.form.attr('action'),
      type: 'GET',
      data: this.form.serialize()
    });
  };

  SearchProductsSearchController.prototype.updateUrlForSearchQuery = function() {
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

    /*
     * we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
     * to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
     */
    url = decodeURIComponent('?' + $.param(filtered_params));
    return History.replaceState(params, this.container.find('input[name=meta_title]').val(), url);
  };

  SearchProductsSearchController.prototype.updateLinksForSearchQuery = function() {
    return this.getSearchParams();
  };

  SearchProductsSearchController.prototype.getSearchParams = function() {
    var form_params, k, param, params;
    form_params = this.form.serializeArray();
    form_params = this.replaceWithData(form_params);

    /*
     * don't polute url if this is unnecessary - ignore empty values and page
     */
    params = [];
    for (k in form_params) {
      param = form_params[k];
      params.push(param);
    }
    return params;
  };

  SearchProductsSearchController.prototype.autocompleteCategories = function() {
    var self;
    self = this;
    if (!(this.container.find('input[data-category-autocomplete]').length > 0)) {
      return;
    }
    return $.each(this.container.find('input[data-category-autocomplete]'), function(
      index,
      select
    ) {
      var apiUrl, selected;
      selected = JSON.parse($(select).attr('data-selected-categories'));
      apiUrl = $(select).attr('data-api-category-path');
      return $(select).select2({
        multiple: true,
        initSelection: function(element, callback) {
          var url;
          url = apiUrl;
          return $.getJSON(url, { init_selection: 'true', ids: selected }, function(data) {
            return callback(data);
          });
        },
        ajax: {
          url: apiUrl,
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
        return self.triggerSearchFromQuery();
      }).select2('val', selected.join(','));
    });
  };

  return SearchProductsSearchController;
}(SearchController);

module.exports = SearchProductsSearchController;
