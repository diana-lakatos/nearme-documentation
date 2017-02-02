module.exports = class SeeMore
  constructor: ->
    @bindEvents()

  bindEvents: ->
    $('form.sort-form').on 'change', (e) ->
      $(e.target).submit()

    $("[data-see-more] button").on "click", (event) ->
      event.preventDefault()
      $button = $(event.target)
      nextPage = $button.data('next-page')
      moreUrl = $button.data("url")
      sortType = $button.closest('.tab-pane').find('form.sort-form select[name="[sort]"]').val()

      if /page=/i.test(moreUrl)
        moreUrl = moreUrl.replace(/page=\d/, "page=#{nextPage}")
      else
        moreUrl = moreUrl + "&page=#{nextPage}"

      if /sort=/i.test(moreUrl)
        moreUrl = moreUrl.replace(/sort=[\w ]*/, "sort=#{sortType}")
      else
        moreUrl = moreUrl + "&sort=#{sortType}"

      $.get moreUrl
