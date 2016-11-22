AddressController = require('../address_controller')

module.exports = class GroupForm
  constructor: (@form) ->
    @coverImageWrapper = $('.media-group.cover-image')
    @videoUploadWrapper = $('.media-group.group-videos')
    @addressFieldController = new AddressController($('.address-form')).addressFieldController;
    @autocomplete = @addressFieldController.address.autocomplete;

    @bindEvents()

  bindEvents: ->
    $('.members-listing-a').on 'click', 'button', (e) =>
      @updateGroupMember(e, true)

    $('.members-listing-a').on 'click', 'input#toggle_moderator_rights', (e) =>
      @updateGroupMember(e, false)

    @initAddressField()
    @initGroupTypeDescription()
    @initCoverImage()
    @initVideoField()
    @initSearchForMemberField()

  initAddressField: ->
    $locationForm = $('.address-form')
    $map = $('.map', $locationForm);
    $markedToDeleteField = $('.marked-to-delete', $locationForm)
    $addressField = $('[data-behavior=address-autocomplete]', $locationForm)
    $removeAddress = $('.remove-address')

    map = @addressFieldController.map

    $addressField.after($removeAddress)

    if $addressField.val().length
      $locationForm.removeClass('no-address')

    $removeAddress.on 'click', (event) ->
      event.preventDefault()

      $addressField.val('')
      $markedToDeleteField.val(true)
      $locationForm.addClass('no-address')

    google.maps.event.addListener @autocomplete, 'place_changed', =>
      $markedToDeleteField.val(false)
      $locationForm.removeClass('no-address')

      setTimeout (=>
        google.maps.event.trigger(map.map, 'resize')
        map.map.setCenter(map.marker.getPosition())
      ), 0

  initGroupTypeDescription: ->
    $groupTypeSelect = $('#group_transactable_type_id')
    $groupDescriptions = $('.group-type-description p')
    selected = $('option:selected', $groupTypeSelect).text().toLowerCase()

    $groupTypeSelect.on 'change', (event) =>
      $groupDescriptions.removeClass('active');
      selected = $(event.target).text().toLowerCase();
      $('.' + selected).addClass('active')

  initCoverImage: ->
    $label = @coverImageWrapper.find('label')
    $input = @coverImageWrapper.find('input')

    $input.on 'change', (event) =>
      str =  $input.val().replace('C:\\fakepath\\','')
      $label.text(str)

  initVideoField: ->
    $input = @videoUploadWrapper.find('input[name=video-url]')
    $submit = @videoUploadWrapper.find('.video-form button')
    $videoForm = @videoUploadWrapper.find('.video-form')
    $videoGallery = @videoUploadWrapper.find('.gallery-video')
    i18nButtonText = $submit.text()

    requestInProgress = ->
      $submit.text('Uploading...')
      $input.prop('disabled', true)

    requestDone = ->
      $input.val('');
      $submit.text(i18nButtonText)
      $input.prop('disabled', false)

    $videoGallery.on 'click', '.remove-video', (event) ->
      event.preventDefault()
      $(this).parent().remove()

    $videoGallery
      .on 'mouseover', 'li', (event) => $('li').addClass('active');
      .on 'mouseout', 'li', (event) => $('li').removeClass('active');

    $submit.on 'click', (event) =>
      event.preventDefault();
      requestInProgress()
      @videoUploadWrapper.find('.error-block').remove()

      $.ajax
        type: 'GET',
        url: $submit.data('href'),
        dataType: "json",
        data: { video_url: $input.val() },
        success: (data) ->
          requestDone()
          $videoGallery.append(data.html)
        error: (data) ->
          requestDone()
          $errorBlock = $('<p>', {class: 'error-block'})
            .hide()
            .text(data.responseJSON.errors.video_url[0])

          $errorBlock.insertAfter($videoForm).show('fast')

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

  updateGroupMember: (event, showConfirmDialog) ->
    event.preventDefault()
    $target = $(event.currentTarget)
    request_method = $target.attr("data-action")
    that = @
    url = $target.attr("data-href")

    triggerRequest = ->
      $.ajax
        type: request_method,
        url: url,
        dataType: "json",
        success: (data) -> that.handle_success(data, request_method, event)
        complete: (data) -> that.handle_success(data, request_method, event)

    if showConfirmDialog && confirm("Are you sure you want to continue?")
      triggerRequest()

    if !showConfirmDialog
      triggerRequest()


  handle_success: (data, request_method, event) =>
    if request_method == "DELETE"
      $(event.target).parents("tr").hide("slow")
    else
      $(event.target).parents("tr").replaceWith(data.html)
