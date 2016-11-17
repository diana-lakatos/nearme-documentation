module.exports = class ExternalLinks

  constructor : (context = 'body') ->
    @context = $(context)
    @bindEvents()

  bindEvents: ->
    @context.on 'click', 'a[rel*="external"]', (e)=>
      url = $(e.target).closest('a').attr('href')
      e.preventDefault()
      window.open url
