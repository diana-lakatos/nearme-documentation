var ExternalLinks;

ExternalLinks = function() {
  function ExternalLinks(context) {
    if (context == null) {
      context = 'body';
    }
    this.context = $(context);
    this.bindEvents();
  }

  ExternalLinks.prototype.bindEvents = function() {
    return this.context.on('click', 'a[rel*="external"]', function(e) {
      var url;
      url = $(e.target).closest('a').attr('href');
      e.preventDefault();
      return window.open(url);
    });
  };

  return ExternalLinks;
}();

module.exports = ExternalLinks;
