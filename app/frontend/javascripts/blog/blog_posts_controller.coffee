window.IASCallbacks = require('exports?IASCallbacks!../vendor/jquery-ias/callbacks')
require('../vendor/jquery-ias/jquery-ias')
urlUtil = require('../lib/utils/url')

module.exports = class BlogPostsController

  constructor: ->
    @initializeInfiniteScroll()

  initializeInfiniteScroll: ->
    ias = jQuery.ias({
      container: '.blog-posts',
      item: '.blog-post',
      pagination: '.pagination',
      next: '.pagination .next_page',
      triggerPageThreshold: 99,
      history: false,
      loader: '<div class="spinner col-xs-12"><h1><img src="' + urlUtil.assetUrl('spinner.gif') + '"></div>'
    })

    ias.on 'rendered', (items) ->
      $(document).trigger('rendered-blog:ias.nearme', [items])
