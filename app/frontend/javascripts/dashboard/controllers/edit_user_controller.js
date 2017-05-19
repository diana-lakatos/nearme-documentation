var EditUserController;

EditUserController = function() {
  function EditUserController(el) {
    this.container = $(el);
    this.bindEvents();
  }

  EditUserController.prototype.bindEvents = function() {
    return this.container.on('click', '.provider-not-disconnectable', function() {
      $('#user_password').effect('highlight', {}, 3000).focus();
      $('#fill-password-request').removeClass('hidden');
      return false;
    });
  };

  return EditUserController;
}();

module.exports = EditUserController;
