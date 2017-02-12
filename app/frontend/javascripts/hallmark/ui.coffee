require('./vendor/vequalize')
require('imports?this=>window!./vendor/tinynav')

module.exports = class UI
  constructor: ->

  # makes elements with data-equalize attribute the same height
  @equalize: ->
    prop = if !document.addEventListener then 'height' else 'outerHeight'
    $('[data-equalize]').vEqualize(height: prop)

  # toggle navigation visibility
  @nav: ->
    body = $('body')
    $('[data-nav]').on 'click', (event) ->
      event.preventDefault()
      body.toggleClass 'is-nav'

  # expand read more sections
  @readmore: ->
    $('body').on 'click', '.readmore-a', (event) ->
      event.preventDefault()
      $(this).addClass 'is-active'

  # init tinyNav for tabs navigation
  @tabsStatic: ->
    $('.tabs-a ul:not(.nav-tabs)').tinyNav active: 'is-active'

  @tabsDynamic: ->
    $('.tabs-a ul.nav-tabs').each ->
      list = $(this)
      tabs = list.find('[role="tab"]')

      select = $('<select/>')
      tabs.each ->
        option = $('<option>',{
          value: $(this).attr('href')
          text: $(this).text()
        })
        option.appendTo(select)

      select.on 'change', (e) ->
        href = $(this).val()
        tabs.filter('[href="' + href + '"]').tab('show')

      tabs.on 'click', (e) ->
        href = $(this).attr('href')
        select.val(href)

      list.after(select)

  @tabsClickSetHashOverride: ->
    $(document).on 'click.hallmark.tabs', '[data-toggle="tab"]', ->
      # By default, hash is not set when clicking tabs
      # We need hashes set but without scrolling to that area of the page
      history.replaceState({}, '', $(this).attr('href'))

  @activeTabFromAnchor: ->
    anchor = window.location.hash.substring(1)
    parent_tab = ''
    tab = ''

    if anchor.length > 0
      parent_match = anchor.match(/([a-z]+)-([a-z]+)/i)
      if parent_match
        parent_tab = $("[href='##{parent_match[1]}'][data-toggle=tab]")

      tab = $("[href='##{anchor}'][data-toggle=tab]")
    else
      tab = $("[data-toggle=tab]:first")

    if parent_tab.length > 0
      parent_tab.click()
    if tab.length > 0
      tab.click()


  @initialize: ->
    @equalize()
    @nav()
    @readmore()
    @tabsStatic()
    @tabsDynamic()
    @activeTabFromAnchor()
    @tabsClickSetHashOverride()


