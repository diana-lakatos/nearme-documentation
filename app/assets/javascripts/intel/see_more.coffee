class @SeeMore
  constructor: ->
    @events()

  events: ->
    $buttons = $("[data-see-more]").find("a")
    $('form.sort-form').on 'change', (e) ->
      $(e.target).submit()

    $buttons.on "click", (event)->
      event.preventDefault()
      $button = $(event.target)
      nextPage = $button.data('next-page')
      moreUrl = $button.attr("href")
      sortType = $button.closest('.tab-pane').find('form.sort-form select[name="[sort]"]').val()

      if /page=/i.test(moreUrl)
        moreUrl = moreUrl.replace(/page=\d/, "page=#{nextPage}")
      else
        moreUrl = moreUrl + "&page=#{nextPage}"

      if /sort=/i.test(moreUrl)
        moreUrl = moreUrl.replace(/sort=[\w ]*/, "sort=#{sortType}")
      else
        moreUrl = moreUrl + "&sort=#{sortType}"

      $button.attr("href", moreUrl)


  @initialize: ->
    new SeeMore()