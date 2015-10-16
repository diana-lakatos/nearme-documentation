class @SeeMore
  constructor: ->
    @setupAttributes()
    @events()

  setupAttributes: ->
    if window.seeMoreAttributes == undefined
      window.seeMoreAttributes = new Object(
        activityFeed:       { page: 1 },
        followingPeople:    { page: 1 },
        followingProjects:  { page: 1 },
        followingTopics:    { page: 1 },
        following:          { page: 1 },
        followers:          { page: 1 },
        projects:           { page: 1 }
      )

  events: ->
    $buttons = $("[data-see-more]").find("a")

    $buttons.on "click", (event)->
      event.preventDefault()
      $button = $(event.target)
      type = $button.parent("[data-see-more]").attr("data-see-more-type")
      oldPage = window.seeMoreAttributes[type].page
      nextPage = window.seeMoreAttributes[type].page++ && window.seeMoreAttributes[type].page
      moreUrl = $button.attr("href")

      if /page=/i.test(moreUrl)
        $button.attr("href", moreUrl.replace("page=#{oldPage}", "page=#{nextPage}"))
      else
        $button.attr("href", moreUrl + "&page=#{nextPage}")


  @initialize: ->
    new SeeMore()