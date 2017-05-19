var UtilUrl;

UtilUrl = {
  getParameterByName: function(name) {
    var regex, results;
    name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
    regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
    results = regex.exec(location.search);
    if (results === null) {
      return '';
    } else {
      return decodeURIComponent(results[1].replace(/\+/g, ' '));
    }
  },
  assetUrl: function(path) {
    return window.NM_ASSET_HOST + '/assets/' + path;
  }
};

module.exports = UtilUrl;
