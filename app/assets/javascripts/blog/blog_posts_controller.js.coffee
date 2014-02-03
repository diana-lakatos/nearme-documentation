class @Blog.BlogPostsController

  constructor: (@container) ->
    @initializeInfiniteScroll()

  initializeInfiniteScroll: =>
    jQuery.ias({
      container : '.blog-posts',
      item: '.blog-post',
      pagination: '.footer',
      next: '.footer .next_page',
      triggerPageThreshold: 99
    })
