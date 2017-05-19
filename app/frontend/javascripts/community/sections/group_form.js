/* global google */
var AddressController, GroupForm;

AddressController = require('../address_controller');

GroupForm = function() {
  function GroupForm(form) {
    this.form = form;
    this.coverImageWrapper = $('.media-group.cover-image');
    this.videoUploadWrapper = $('.media-group.group-videos');
    this.addressFieldController = new AddressController($('.address-form')).addressFieldController;
    this.autocomplete = this.addressFieldController.address.autocomplete;
    this.bindEvents();
  }

  GroupForm.prototype.bindEvents = function() {
    $('.members-listing-a').on(
      'click',
      'button',
      function(_this) {
        return function(e) {
          return _this.updateGroupMember(e, true);
        };
      }(this)
    );
    $('.members-listing-a').on(
      'click',
      'input#toggle_moderator_rights',
      function(_this) {
        return function(e) {
          return _this.updateGroupMember(e, false);
        };
      }(this)
    );
    this.initAddressField();
    this.initGroupTypeDescription();
    this.initCoverImage();
    this.initVideoField();
    return this.initSearchForMemberField();
  };

  GroupForm.prototype.initAddressField = function() {
    var $addressField, $locationForm, $markedToDeleteField, $removeAddress, map;
    $locationForm = $('.address-form');
    $markedToDeleteField = $('.marked-to-delete', $locationForm);
    $addressField = $('[data-behavior=address-autocomplete]', $locationForm);
    $removeAddress = $('.remove-address');
    map = this.addressFieldController.map;
    $addressField.after($removeAddress);
    if ($addressField.val().length) {
      $locationForm.removeClass('no-address');
    }
    $removeAddress.on('click', function(event) {
      event.preventDefault();
      $addressField.val('');
      $markedToDeleteField.val(true);
      return $locationForm.addClass('no-address');
    });
    return google.maps.event.addListener(this.autocomplete, 'place_changed', function() {
      $markedToDeleteField.val(false);
      $locationForm.removeClass('no-address');
      return setTimeout(
        function() {
          google.maps.event.trigger(map.map, 'resize');
          return map.map.setCenter(map.marker.getPosition());
        },
        0
      );
    });
  };

  GroupForm.prototype.initGroupTypeDescription = function() {
    var $groupDescriptions, $groupTypeSelect, selected;
    $groupTypeSelect = $('#group_transactable_type_id');
    $groupDescriptions = $('.group-type-description p');
    selected = $('option:selected', $groupTypeSelect).text().toLowerCase();
    return $groupTypeSelect.on('change', function(event) {
      $groupDescriptions.removeClass('active');
      selected = $(event.target).text().toLowerCase();
      return $('.' + selected).addClass('active');
    });
  };

  GroupForm.prototype.initCoverImage = function() {
    var $input, $label;
    $label = this.coverImageWrapper.find('label');
    $input = this.coverImageWrapper.find('input');
    return $input.on('change', function() {
      var str;
      str = $input.val().replace('C:\\fakepath\\', '');
      return $label.text(str);
    });
  };

  GroupForm.prototype.initVideoField = function() {
    var $input, $submit, $videoForm, $videoGallery, i18nButtonText, requestDone, requestInProgress;
    $input = this.videoUploadWrapper.find('input[name=video-url]');
    $submit = this.videoUploadWrapper.find('.video-form button');
    $videoForm = this.videoUploadWrapper.find('.video-form');
    $videoGallery = this.videoUploadWrapper.find('.gallery-video');
    i18nButtonText = $submit.text();
    requestInProgress = function() {
      $submit.text('Uploading...');
      return $input.prop('disabled', true);
    };
    requestDone = function() {
      $input.val('');
      $submit.text(i18nButtonText);
      return $input.prop('disabled', false);
    };
    $videoGallery.on('click', '.remove-video', function(event) {
      event.preventDefault();
      return $(this).parent().remove();
    });
    $videoGallery.on('mouseover', 'li', function() {
      return $videoGallery.find('li').addClass('active');
    }).on('mouseout', 'li', function() {
      return $videoGallery.find('li').removeClass('active');
    });
    return $submit.on(
      'click',
      function(_this) {
        return function(event) {
          event.preventDefault();
          requestInProgress();
          _this.videoUploadWrapper.find('.error-block').remove();
          return $.ajax({
            type: 'GET',
            url: $submit.data('href'),
            dataType: 'json',
            data: { video_url: $input.val() },
            success: function(data) {
              requestDone();
              return $videoGallery.append(data.html);
            },
            error: function(data) {
              var $errorBlock;
              requestDone();
              $errorBlock = $('<p>', { 'class': 'error-block' })
                .hide()
                .text(data.responseJSON.errors.video_url[0]);
              return $errorBlock.insertAfter($videoForm).show('fast');
            }
          });
        };
      }(this)
    );
  };

  GroupForm.prototype.initSearchForMemberField = function() {
    var $input, $submit;
    $input = $('#search-for-member');
    $submit = $('#search-for-member-submit');
    return $submit.on('click', function(event) {
      event.preventDefault();
      return $.ajax({
        type: 'GET',
        url: $submit.data('href'),
        dataType: 'json',
        data: { phrase: $input.val() },
        success: function(data) {
          return $('.members-listing-a tbody').html(data.html);
        }
      });
    });
  };

  GroupForm.prototype.updateGroupMember = function(event, showConfirmDialog) {
    var $target, request_method, that, triggerRequest, url;
    event.preventDefault();
    $target = $(event.currentTarget);
    request_method = $target.attr('data-action');
    that = this;
    url = $target.attr('data-href');
    triggerRequest = function() {
      return $.ajax({
        type: request_method,
        url: url,
        dataType: 'json',
        success: function(data) {
          return that.handle_success(data, request_method, event);
        },
        complete: function(data) {
          return that.handle_success(data, request_method, event);
        }
      });
    };
    if (showConfirmDialog && confirm('Are you sure you want to continue?')) {
      triggerRequest();
    }
    if (!showConfirmDialog) {
      return triggerRequest();
    }
  };

  GroupForm.prototype.handle_success = function(data, request_method, event) {
    if (request_method === 'DELETE') {
      return $(event.target).parents('tr').hide('slow');
    } else {
      return $(event.target).parents('tr').replaceWith(data.html);
    }
  };

  return GroupForm;
}();

module.exports = GroupForm;
