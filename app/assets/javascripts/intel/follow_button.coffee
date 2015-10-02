class @FollowButton
  constructor: ->
    @switchButtonClass()
    @events()

  events: ->
    $buttons = $("[data-follow-button]").find("a")
    $buttons.on "click", ->
      window.clickedFollowButton = $(@)
      window.clickedFollowButtonClasses = $(@).attr("class")


  switchButtonClass: ->
    if window.newFollowButton?
      window.newFollowButton.attr("class", window.clickedFollowButtonClasses)

  @initialize: ->
    new FollowButton()
