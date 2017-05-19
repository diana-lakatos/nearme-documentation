var SearchController,
  SearchProductsTableSearchController,
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

SearchProductsTableSearchController = function(superClass) {
  extend(SearchProductsTableSearchController, superClass);

  function SearchProductsTableSearchController(form, container) {
    this.form = form;
    this.container = container;
    this.initializeSearchButton();
    this.responsiveCategoryTree();
    this.filters_container = $('[data-search-filters-container]');
    this.unfilteredPrice = 0;
    this.bindEvents();
    this.initializePriceSlider();
  }

  SearchProductsTableSearchController.prototype.bindEvents = function() {
    return this.filters_container.on(
      'click',
      'input[type=checkbox]',
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

  SearchProductsTableSearchController.prototype.triggerSearchFromQuery = function(page) {
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
    return this.form.submit();
  };

  SearchProductsTableSearchController.prototype.initializeSearchButton = function() {
    return $('.span12 .search-icon').click(function() {
      return $('form.search_results').submit();
    });
  };

  return SearchProductsTableSearchController;
}(SearchController);

module.exports = SearchProductsTableSearchController;
