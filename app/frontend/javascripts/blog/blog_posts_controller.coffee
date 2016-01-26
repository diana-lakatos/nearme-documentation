window.IASCallbacks = require('exports?IASCallbacks!jquery-ias/src/callbacks')
require('jquery-ias/src/jquery-ias');

module.exports = class BlogPostsController

  constructor: () ->
    @initializeInfiniteScroll()

  initializeInfiniteScroll: =>
    $.ias({
      container: '.blog-posts',
      item: '.blog-post',
      pagination: '.pagination',
      next: '.pagination .next_page',
      triggerPageThreshold: 99,
      history: false,
      loader: '<div class="spinner col-xs-12"><h1><img src="' + $('img[alt=Spinner]').eq(0).attr('src') + '"></div>',
    })
