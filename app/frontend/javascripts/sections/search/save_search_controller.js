var SearchSaveSearchController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

SearchSaveSearchController = function() {
  function SearchSaveSearchController() {
    this.saveSearch = bind(this.saveSearch, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.bindEvents();
  }

  SearchSaveSearchController.prototype.bindEvents = function() {
    $('a[data-save-search]').on(
      'click',
      function(_this) {
        return function(event) {
          event.preventDefault();
          return _this.showSaveSearchDialog();
        };
      }(this)
    );
    $('button[data-save-search-submit]').on(
      'click',
      function(_this) {
        return function(event) {
          event.preventDefault();
          return _this.saveSearch();
        };
      }(this)
    );
    return $('input[data-save-search-title]').on(
      'keyup',
      function(_this) {
        return function(event) {
          if (event.keyCode === 13) {
            event.preventDefault();
            $('div[data-save-search-modal]').modal('hide');
            return _this.saveSearch();
          }
        };
      }(this)
    );
  };

  SearchSaveSearchController.prototype.showSaveSearchDialog = function() {
    $('div[data-save-search-modal]').modal('show');
    return $('input[data-save-search-title]').focus();
  };

  SearchSaveSearchController.prototype.saveSearch = function() {
    var title;
    title = $('input[data-save-search-title]').val();
    $('input[data-save-search-title]').val('');
    return $.ajax({
      type: 'POST',
      dataType: 'JSON',
      url: '/dashboard/saved_searches/',
      data: { saved_search: { title: title, query: window.location.search } },
      success: function(_this) {
        return function(data) {
          return _this.showSaveStatusDialog(data['success'], data['title']);
        };
      }(this),
      error: function(_this) {
        return function() {
          return _this.showSaveStatusDialog(false);
        };
      }(this)
    });
  };

  SearchSaveSearchController.prototype.showSaveStatusDialog = function(success, title) {
    var errorTag, successTag;
    if (title == null) {
      title = null;
    }
    successTag = $('h4[data-save-search-status-success]');
    errorTag = $('h4[data-save-search-status-error]');
    if (success) {
      errorTag.hide();
      successTag.text(successTag.text().replace(':title', title));
      successTag.show();
    } else {
      successTag.hide();
      errorTag.show();
    }
    return $('div[data-save-search-status-modal]').modal('show');
  };

  return SearchSaveSearchController;
}();

module.exports = SearchSaveSearchController;
