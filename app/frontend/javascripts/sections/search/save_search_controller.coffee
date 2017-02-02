module.exports = class SearchSaveSearchController

  constructor: ->
    @bindEvents()

  bindEvents: =>
    $('a[data-save-search]').on 'click', (event) =>
      event.preventDefault()
      @showSaveSearchDialog()

    $('button[data-save-search-submit]').on 'click', (event) =>
      event.preventDefault()
      @saveSearch()

    $('input[data-save-search-title]').on 'keyup', (event) =>
      if event.keyCode == 13
        event.preventDefault()
        $('div[data-save-search-modal]').modal('hide')
        @saveSearch()

  showSaveSearchDialog: ->
    $('div[data-save-search-modal]').modal('show')
    $('input[data-save-search-title]').focus()

  saveSearch: =>
    title = $('input[data-save-search-title]').val()
    $('input[data-save-search-title]').val('')
    $.ajax
      type: 'POST'
      dataType: 'JSON'
      url: '/dashboard/saved_searches/'
      data: {saved_search: {title: title, query: window.location.search}}
      success: (data) =>
        @showSaveStatusDialog(data['success'], data['title'])
      error: =>
        @showSaveStatusDialog(false)

  showSaveStatusDialog: (success, title = null) ->
    successTag = $('h4[data-save-search-status-success]')
    errorTag = $('h4[data-save-search-status-error]')
    if success
      errorTag.hide()
      successTag.text(successTag.text().replace(':title', title))
      successTag.show()
    else
      successTag.hide()
      errorTag.show()

    $('div[data-save-search-status-modal]').modal('show')
