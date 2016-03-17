URLify = require('imports?window=>{}!exports?window.URLify!urlify');

module.exports = class BlogPostsForm

  constructor: () ->
    @form = $(form)
    @title = @form.find('#blog_post_title')
    @slug = @form.find('#blog_post_slug')
    @slug_changed = @title.data('slug_changed') == 'true'
    @bindEvents()

  bindEvents: ->
    @slug.on 'keyup keydown keypress change paste', =>
      @slug_changed = true

    @title.on 'keyup keydown keypress change paste', =>
      if not @slug_changed
        value = URLify(@title.val())
        @slug.val(value)

    @form.find('.toolbar button').click (e) ->
      e.preventDefault()
