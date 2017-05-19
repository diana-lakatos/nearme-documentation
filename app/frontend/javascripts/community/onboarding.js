var AddressController, Onboarding;

AddressController = require('./address_controller');

Onboarding = function() {
  function Onboarding() {}

  /*
   * toggles is-active class on parent container on onboarding: follow page
   */
  Onboarding.followCheckboxes = function() {
    return $('.card-b input').on('change.card', function() {
      return $(this).closest('.card-b').toggleClass('is-active', $(this).prop('checked'));
    });
  };

  /*
   * geolocation when entering user location
   */
  Onboarding.locationSelector = function() {
    if (!(window.google && window.google.maps)) {
      return;
    }
    return new AddressController($('.form-a .fields.location'));
  };

  Onboarding.initialize = function() {
    this.followCheckboxes();
    return this.locationSelector();
  };

  return Onboarding;
}();

module.exports = Onboarding;
