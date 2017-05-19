var SearchListSearchController,
  SearchSearchController,
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

SearchSearchController = require('./search_controller');

SearchListSearchController = function(superClass) {
  extend(SearchListSearchController, superClass);

  function SearchListSearchController(form, container) {
    this.container = container;
    this.reinitializePriceSlider = bind(this.reinitializePriceSlider, this);
    SearchListSearchController.__super__.constructor.call(this, form, this.container);
    this.initializePriceSlider();
  }

  SearchListSearchController.prototype.reinitializePriceSlider = function() {
    $('#price-slider').remove();
    $('.price-slider-container').append('<div id="price-slider"></div>');
    return SearchListSearchController.__super__.reinitializePriceSlider.apply(this, arguments);
  };

  return SearchListSearchController;
}(SearchSearchController);

module.exports = SearchListSearchController;
