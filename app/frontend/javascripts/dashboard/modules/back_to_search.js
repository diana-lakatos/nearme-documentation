var BackToSearch;

require('jquery.cookie/jquery.cookie');

BackToSearch = function() {
  function BackToSearch(el) {
    this.backToSearch = $(el);
    this.setupBackToSearchLink();
  }

  BackToSearch.prototype.setupBackToSearchLink = function() {
    var params;
    if (this.backToSearch.length > 0 && $.cookie('last_search')) {
      params = $.param($.parseJSON($.cookie('last_search')));
      return this.backToSearch.attr('href', '/search?' + params);
    }
  };

  return BackToSearch;
}();

module.exports = BackToSearch;
