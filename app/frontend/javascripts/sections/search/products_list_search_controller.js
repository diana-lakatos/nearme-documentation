var SearchController,
  SearchProductsListSearchController,
  SearchScreenLockLoader,
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

SearchController = require('./controller');

SearchScreenLockLoader = require('./screen_lock_loader');

window.IASCallbacks = require('exports?IASCallbacks!../../vendor/jquery-ias/callbacks');

require('../../vendor/jquery-ias/jquery-ias');

SearchProductsListSearchController = function(superClass) {
  extend(SearchProductsListSearchController, superClass);

  function SearchProductsListSearchController(form, container) {
    this.form = form;
    this.container = container;
    this.initializeEndlessScrolling();
    this.initializeSearchButton();
    this.responsiveCategoryTree();
    this.filters_container = $('[data-search-filters-container]');
    this.loader = new SearchScreenLockLoader(
      function(_this) {
        return function() {
          return _this.container.find('.loading');
        };
      }(this)
    );
    this.unfilteredPrice = 0;
    this.bindEvents();
    this.initializePriceSlider();
  }

  SearchProductsListSearchController.prototype.bindEvents = function() {
    return this.filters_container.on(
      'click',
      'input[type=checkbox]:not(.nav-heading > label > input)',
      function(_this) {
        return function() {
          return setTimeout(function() {
            _this.triggerSearchFromQuery();
            return 100;
          });
        };
      }(this)
    );
  };

  SearchProductsListSearchController.prototype.triggerSearchFromQuery = function(page) {
    if (page == null) {
      page = false;
    }
    this.assignFormParams({
      ignore_search_event: 0,
      category_ids: _.toArray(
        this.container.find('input[name="category_ids[]"]:checked').map(function() {
          return $(this).val();
        })
      ).join(','),
      page: page || 1
    });
    this.loader.showWithoutLocker();
    return this.form.submit();
  };

  SearchProductsListSearchController.prototype.initializeSearchButton = function() {
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

  SearchProductsListSearchController.prototype.initializeEndlessScrolling = function() {
    var ias;
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
        '"><span>Loading More Results</span></h1></div>'
    });
    return ias.on('rendered', function(items) {
      return $(document).trigger('rendered-search:ias.nearme', [ items ]);
    });
  };

  return SearchProductsListSearchController;
}(SearchController);

module.exports = SearchProductsListSearchController;
