var InstanceAdminLocationsController,
  urlUtil,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

urlUtil = require('../../lib/utils/url');

InstanceAdminLocationsController = function() {
  function InstanceAdminLocationsController(editLocationTypesForm) {
    this.editLocationTypesForm = editLocationTypesForm;
    this.updateLocationType = bind(this.updateLocationType, this);
    this.bindEvents();
  }

  InstanceAdminLocationsController.prototype.bindEvents = function() {
    var inputs;
    inputs = this.editLocationTypesForm.find('input.location-type-name');
    inputs.on(
      'focusin',
      function(_this) {
        return function(event) {
          event.preventDefault();
          return _this.currentValue = $(event.target).val();
        };
      }(this)
    );
    inputs.on(
      'focusout',
      function(_this) {
        return function(event) {
          event.preventDefault();
          return _this.updateLocationType(event);
        };
      }(this)
    );
    inputs.on(
      'keyup',
      function(_this) {
        return function(event) {
          if (event.keyCode === 13) {
            return _this.updateLocationType(event);
          }
        };
      }(this)
    );
    return $('a[data-location-types-instance-admin-modal]').click(function(event) {
      var target;
      event.preventDefault();
      target = $(this).attr('href');
      $('#instanceAdminModal .modal-content').load(target, function() {
        $('#instanceAdminModal').modal('show');
      });
    });
  };

  InstanceAdminLocationsController.prototype.updateLocationType = function(event) {
    var entry, locationTypeId, modifiedValue, self;
    self = $(event.target);
    modifiedValue = self.val();
    if (!!modifiedValue && !!this.currentValue && modifiedValue !== this.currentValue) {
      entry = self.closest('div.location-type-entry');
      locationTypeId = entry.find('input.location-type-id').val();
      $.ajax({
        url: this.editLocationTypesForm.attr('action').replace(':id', locationTypeId),
        type: 'PATCH',
        dataType: 'JSON',
        data: { location_type: { name: modifiedValue } },
        success: function(_this) {
          return function(data) {
            return _this.blinkImage(entry, data['success']);
          };
        }(this),
        error: function() {
          return this.blinkImage(entry, false);
        }
      });
    }
    return this.currentValue = null;
  };

  InstanceAdminLocationsController.prototype.blinkImage = function(entry, success) {
    var image, img;
    image = success ? 'green-check' : 'x-red';
    img = $('<img>').attr('src', urlUtil.assetUrl('dashboard/' + image + '.png')).hide();
    entry.append(img);
    return img.fadeIn('slow', function() {
      return img.fadeOut('slow', function() {
        return img.remove();
      });
    });
  };

  return InstanceAdminLocationsController;
}();

module.exports = InstanceAdminLocationsController;
