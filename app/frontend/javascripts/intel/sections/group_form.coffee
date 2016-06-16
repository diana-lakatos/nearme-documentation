module.exports = class GroupForm
  constructor: (@form) ->
    @coverImageWrapper = $('.media-group.cover-image')
    @bindEvents()

  bindEvents: ->
    $('.members-listing-a').on 'click', 'button', (e) =>
      @updateProjectCollaborator(e)

    @initCoverImage()
    @initVideoField()
    @initSearchForMemberField()

  initCoverImage: ->
    $label = @coverImageWrapper.find('label')
    $input = @coverImageWrapper.find('input')

    $input.on 'change', (event) =>
      str =  $input.val().replace('C:\\fakepath\\','')
      $label.text(str)

  initVideoField: ->
    $input = $('#video-url')
    $submit = $('#video-submit')

    $('.gallery-video').on 'click', '.remove-video', (event) ->
      event.preventDefault()
      $(this).parent().remove()

    $submit.on 'click', (event) =>
      event.preventDefault();
      $.ajax
        type: 'GET',
        url: $submit.data('href'),
        dataType: "json",
        data: { video_url: $input.val() },
        success: (data) ->
          $('.gallery-video').append(data.html)

  initSearchForMemberField: ->
    $input = $('#search-for-member')
    $submit = $('#search-for-member-submit')

    $submit.on 'click', (event) =>
      event.preventDefault();
      $.ajax
        type: 'GET',
        url: $submit.data('href'),
        dataType: "json",
        data: { phrase: $input.val() },
        success: (data) ->
          $('.members-listing-a tbody').html(data.html)

  updateProjectCollaborator: (event) ->
    event.preventDefault()
    request_method = $(event.target).attr("data-action")
    that = @
    url = $(event.target).attr("data-href")

    if confirm("Are you sure you want to continue?")
      $.ajax
        type: request_method,
        url: url,
        dataType: "json",
        success: (data) -> that.handle_success(data, request_method, event)
        complete: (data) -> that.handle_success(data, request_method, event)

  handle_success: (data, request_method, event) =>
    if request_method == "DELETE"
      $(event.target).parents("tr").hide("slow")
    else
      $(event.target).parents("tr").replaceWith(data.html)
