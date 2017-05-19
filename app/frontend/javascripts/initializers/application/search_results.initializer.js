$(document).on('init:list:searchresults.nearme', function() {
  require.ensure('../../sections/search/search_list_search_controller', require => {
    var SearchListSearchController = require('../../sections/search/search_list_search_controller'),
      form = $('#listing_search form'),
      container = $('#content.search');
    return new SearchListSearchController(form, container);
  });
});

$(document).on('init:mixed:searchresults.nearme', function() {
  require.ensure('../../sections/search/search_mixed_controller', require => {
    var SearchMixedController = require('../../sections/search/search_mixed_controller'),
      form = $('#listing_search form'),
      container = $('#results');
    return new SearchMixedController(form, container);
  });
});

$(document).on('init:products:searchresults.nearme', function() {
  require.ensure('../../sections/search/products_search_controller', require => {
    var ProductsSearchController = require('../../sections/search/products_search_controller'),
      form = $('#search_form'),
      container = $('.search-view');
    return new ProductsSearchController(form, container);
  });
});

$(document).on('init:productslist:searchresults.nearme', function() {
  require.ensure('../../sections/search/products_list_search_controller', require => {
    var ProductsListSearchController = require(
      '../../sections/search/products_list_search_controller'
    ),
      form = $('#listing_search form'),
      container = $('#content');

    return new ProductsListSearchController(form, container);
  });
});

$(document).on('init:productstable:searchresults.nearme', function() {
  require.ensure('../../sections/search/products_table_search_controller', require => {
    var ProductsTableSearchController = require(
      '../../sections/search/products_table_search_controller'
    ),
      form = $('#form.search_results'),
      container = $('.search-view');

    return new ProductsTableSearchController(form, container);
  });
});
