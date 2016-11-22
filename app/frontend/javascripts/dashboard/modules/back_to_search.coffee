require('jquery.cookie/jquery.cookie')

module.exports = class BackToSearch
  constructor: (el) ->
    @backToSearch = $(el)
    @setupBackToSearchLink()

  setupBackToSearchLink: ->
    if @backToSearch.length > 0 && $.cookie('last_search')
      params = $.param($.parseJSON($.cookie('last_search')))
      @backToSearch.attr('href', "/search?#{params}")