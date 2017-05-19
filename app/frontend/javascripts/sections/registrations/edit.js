var DashboardAddressController, EditUserForm;

DashboardAddressController = require('../dashboard/address_controller');

EditUserForm = function() {
  function EditUserForm(el) {
    this.container = $(el);
    this.bindEvents();
    new DashboardAddressController($('#edit_user'));
  }

  EditUserForm.prototype.bindEvents = function() {
    $('.services_list').on('click', '.provider-not-disconnectable', function() {
      $('#user_password').effect('highlight', {}, 3000).focus();
      $('#fill-password-request').removeClass('hidden');
      return false;
    });
    return this.container.find('input').on('change paste keyup', function() {
      var profileLink;
      profileLink = $('a.profile-link');
      if (profileLink.length > 0) {
        return $(
          'a.profile-link'
        ).attr('data-confirm', 'You have unsaved changes in your profile. Do you want to leave this page and discard changes?');
      }
    });
  };

  return EditUserForm;
}();

module.exports = EditUserForm;
