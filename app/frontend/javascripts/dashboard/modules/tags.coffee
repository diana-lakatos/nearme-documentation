require 'selectize/dist/js/selectize'

module.exports = class Tags
  constructor: (el)->
    @tagList = $(el)
    @queryUrl = @tagList.data('tags').url + '?q='
    @initSelectize()

  initSelectize: ->

    options = {
      valueField: 'name',
      labelField: 'name',
      searchField: 'name',
      create: true,
      load: (query, callback)=>
        return callback() unless query

        onSuccess = (res)->
          callback(res)

        onError = ()->
          callback()

        $.ajax {
          url: @queryUrl + encodeURIComponent(query),
          type: 'GET',
          error: onError,
          success: onSuccess
        }
    }

    selectizeObj = @tagList.selectize(options)

  atInstanceAdmin: ->
    window.location.href.match(/instance_admin/)
