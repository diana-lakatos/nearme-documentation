var Forms, Search;

require('history.js/history');

require('history.js/history.adapter.ender');

Forms = require('../forms');

Search = (function() {
  function Search(form) {
    this.form = form;
    this.topnavForm = $('form#search_topnav');
    this.topnavFormQuery = $('#topnav_query');
    this.searchTabNav = $('nav.search-types');
    this.searchTabs = $('nav.search-types li a');
    this.actionButtons = $('nav.search-types .actions a');
    this.paginationContainer = $('.pagination-more-a');
    this.bindEvents();
  }

  Search.prototype.queryInput = function() {
    return $('input#_query');
  };

  Search.prototype.pageInput = function() {
    return this.form.find('input#_page');
  };

  Search.prototype.seeMoreLink = function() {
    return this.paginationContainer.find('p.more-a');
  };

  Search.prototype.searchContainer = function() {
    return $('.search-container');
  };

  Search.prototype.searchResults = function() {
    return $('.search-results');
  };

  Search.prototype.bindEvents = function() {
    this.bindForm();
    this.topnavForm.on(
      'submit',
      (function(_this) {
        return function(event) {
          event.preventDefault();
          return _this.triggerSearchAndHandleResults();
        };
      })(this)
    );
    this.paginationContainer.on(
      'click',
      (function(_this) {
        return function(event) {
          event.preventDefault();
          return _this.getNextPage();
        };
      })(this)
    );
    return this.searchTabs.on(
      'click',
      (function(_this) {
        return function(event) {
          event.preventDefault();
          _this.triggerActionButtonsVisibility($(event.target));
          _this.triggerTabSwitchAndHandleResults($(event.target));
          return _this.triggerRelatedDropdownSwitch($(event.target));
        };
      })(this)
    );
  };

  Search.prototype.bindForm = function() {
    this.form = $('form#search_filter');
    return this.form.on(
      'change',
      (function(_this) {
        return function() {
          return _this.triggerSearchAndHandleResults();
        };
      })(this)
    );
  };

  Search.prototype.getNextPage = function() {
    var page;
    page = this.seeMoreLink().data('next-page');
    if (page) {
      this.pageInput().val(page);
    }
    this.triggerSearchRequest().success(
      (function(_this) {
        return function(html) {
          _this.appendResults(html);
          return _this.replaceSeeMore(html);
        };
      })(this)
    );
    return true;
  };

  Search.prototype.triggerActionButtonsVisibility = function(tab) {
    this.actionButtons.removeClass('is-active');
    return this.actionButtons.filter('.' + tab.data('search-type')).addClass('is-active');
  };

  Search.prototype.triggerTabSwitchAndHandleResults = function(tab) {
    var data;
    tab.parents('ul').find('li.is-active').removeClass('is-active');
    tab.parents('li').addClass('is-active');
    data = { search_type: tab.data('search-type'), query: this.topnavFormQuery.val(), page: 1 };
    return this.triggerSearchAndHandleResults(data);
  };

  Search.prototype.triggerRelatedDropdownSwitch = function(tab) {
    var $options, index;
    index = this.searchTabs.index(tab);
    $options = $('select option', this.searchTabNav);
    $options.attr('selected', false);
    return $options.eq(index).attr('selected', true);
  };

  Search.prototype.getSearchType = function() {
    return $('nav.search-types li.is-active a').data('search-type');
  };

  /*
   * Triggers a search with default UX behaviour and semantics.
   */
  Search.prototype.triggerSearchAndHandleResults = function(data) {
    this.queryInput().val(this.topnavFormQuery.val());
    this.pageInput().val(1);
    return this.triggerSearchRequest(data).success(
      (function(_this) {
        return function(html) {
          let searchType = data && data['search_type']
            ? data['search_type']
            : _this.getSearchType();
          _this.showResults(html);
          _this.reinitializeElements();
          _this.replaceSeeMore(html);
          return _this.updateUrlForSearchQuery(searchType);
        };
      })(this)
    );
  };

  Search.prototype.showResults = function(html) {
    return this.searchContainer().replaceWith($(html).find('.search-container'));
  };

  Search.prototype.appendResults = function(html) {
    return this.searchResults().append($(html).find('.search-results').html());
    /*
    #$('.pagination').hide()
     */
  };

  Search.prototype.replaceSeeMore = function(html) {
    if ($(html).find('.pagination-more-a').length > 0) {
      this.paginationContainer.show();
      return this.paginationContainer.html($(html).find('.pagination-more-a').html());
    } else {
      return this.paginationContainer.hide();
    }
  };

  Search.prototype.reinitializeElements = function() {
    Forms.selectize();
    return this.bindForm();
  };

  /*
   * Trigger the API request for search
   * Returns a jQuery Promise object which can be bound to execute response semantics.
   */
  Search.prototype.triggerSearchRequest = function(data) {
    if (this.currentAjaxRequest) {
      this.currentAjaxRequest.abort();
    }
    if (!data) {
      data = this.form.serialize();
    }
    return (this.currentAjaxRequest = $.ajax({
      url: this.form.attr('action'),
      type: 'GET',
      data: data
    }));
  };

  Search.prototype.updateUrlForSearchQuery = function(search_type) {
    var i, len, old_url, params, ref, tab;
    params = this.getSearchParams();

    /*
     * we need to decodeURIComponent, otherwise accents will not be handled correctly. Remove decodeURICompoent if we switch back
     * to window.history.replaceState, but it's *absolutely mandatory* in this case. Removing it now will lead to infiite redirection in IE lte 9
     */
    params = decodeURIComponent('?' + $.param(params));
    ref = this.searchTabs;
    for ((i = 0), (len = ref.length); i < len; i++) {
      tab = ref[i];
      old_url = $(tab).attr('href').split('?')[0];
      $(tab).attr('href', old_url + ('?query=' + this.topnavFormQuery.val()));
    }
    return History.replaceState(params, 'Search Results', '/search/' + search_type + params);
  };

  Search.prototype.getSearchParams = function() {
    var form_params, k, param, params;
    form_params = this.form.serializeArray();

    /*
     * don't polute url if this is unnecessary - ignore empty values and page
     */
    params = [];
    for (k in form_params) {
      param = form_params[k];
      if (
        param['name'] !== 'page' &&
        param['name'] !== 'authenticity_token' &&
        param['value'] !== ''
      ) {
        params.push(param);
      }
    }
    return params;
  };

  return Search;
})();

module.exports = Search;
