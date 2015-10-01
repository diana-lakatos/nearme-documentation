class @SeeMore
  constructor: ->
    @setupAttributes()
    @events()

  setupAttributes: ->
    defaults = new Object(page: 1)

    window.seeMoreAttributes = new Object(
      activityFeed:       defaults,
      followingPeople:    defaults,
      followingProjects:  defaults,
      followingTopics:    defaults,
      following:          defaults,
      followers:          defaults,
      projects:           defaults
    )

  events: ->
    $buttons = $("[data-see-more]").find("a")

    $buttons.on "click", (e)->
      e.preventDefault()
      $button = $(@)
      type = $button.parents("[data-see-more]").attr("data-see-more-type")
      oldPage = window.seeMoreAttributes[type].page
      nextPage = window.seeMoreAttributes[type].page + 1
      moreUrl = $button.attr("href")

      if /page=/i.test(moreUrl)
        $button.attr("href", moreUrl.replace("page=#{oldPage}", "page=#{nextPage}"))
      else
        $button.attr("href", moreUrl + "&page=#{nextPage}")

      window.seeMoreAttributes[type].page = window.seeMoreAttributes[type].page + 1


  @initialize: ->
    new SeeMore()