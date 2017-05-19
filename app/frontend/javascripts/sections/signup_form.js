var ModalForm,
  SignupForm,
  extend = function(child, parent) {
    for (var key in parent) {
      if (hasProp.call(parent, key))
        child[key] = parent[key];
    }
    function ctor() {
      this.constructor = child;
    }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor();
    child.__super__ = parent.prototype;
    return child;
  },
  hasProp = {}.hasOwnProperty;

ModalForm = require('../components/modal_form');

SignupForm = function(superClass) {
  extend(SignupForm, superClass);

  function SignupForm(container) {
    this.container = container;
    this.form = this.container.find('#new_user');
    SignupForm.__super__.constructor.call(this, this.container, this.form);
  }

  SignupForm.prototype.bindEvents = function() {
    return this.container.on(
      'click',
      '.signup-provider .close-button',
      function(_this) {
        return function() {
          _this.container.find('.signup-provider').hide();
          return _this.container.find('.signup-no-provider').fadeIn();
        };
      }(this)
    );
  };

  return SignupForm;
}(ModalForm);

module.exports = SignupForm;
