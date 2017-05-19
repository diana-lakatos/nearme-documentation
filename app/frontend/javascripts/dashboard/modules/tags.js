var Tags;

require('selectize/dist/js/selectize');

Tags = function() {
  function Tags(el) {
    this.tagList = $(el);
    this.queryUrl = this.tagList.data('tags').url + '?q=';
    this.initSelectize();
  }

  Tags.prototype.initSelectize = function() {
    var options;
    options = {
      valueField: 'name',
      labelField: 'name',
      searchField: 'name',
      create: true,
      load: function(_this) {
        return function(query, callback) {
          var onError, onSuccess;
          if (!query) {
            return callback();
          }
          onSuccess = function(res) {
            return callback(res);
          };
          onError = function() {
            return callback();
          };
          return $.ajax({
            url: _this.queryUrl + encodeURIComponent(query),
            type: 'GET',
            error: onError,
            success: onSuccess
          });
        };
      }(this)
    };
    return this.tagList.selectize(options);
  };

  Tags.prototype.atInstanceAdmin = function() {
    return window.location.href.match(/instance_admin/);
  };

  return Tags;
}();

module.exports = Tags;
