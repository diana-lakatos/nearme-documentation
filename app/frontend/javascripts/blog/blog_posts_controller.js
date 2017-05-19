var BlogPostsController, urlUtil;

window.IASCallbacks = require('exports?IASCallbacks!../vendor/jquery-ias/callbacks');

require('../vendor/jquery-ias/jquery-ias');

urlUtil = require('../lib/utils/url');

BlogPostsController = function() {
  function BlogPostsController() {
    this.initializeInfiniteScroll();
  }

  BlogPostsController.prototype.initializeInfiniteScroll = function() {
    var ias;
    ias = jQuery.ias({
      container: '.blog-posts',
      item: '.blog-post',
      pagination: '.pagination',
      next: '.pagination .next_page',
      triggerPageThreshold: 99,
      history: false,
      loader: '<div class="spinner col-xs-12"><h1><img src="' + urlUtil.assetUrl('spinner.gif') +
        '"></div>'
    });
    return ias.on('rendered', function(items) {
      return $(document).trigger('rendered-blog:ias.nearme', [ items ]);
    });
  };

  return BlogPostsController;
}();

module.exports = BlogPostsController;
