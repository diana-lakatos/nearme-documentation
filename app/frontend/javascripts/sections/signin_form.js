var ModalForm,
  SigninForm,
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

SigninForm = function(superClass) {
  extend(SigninForm, superClass);

  function SigninForm(container) {
    this.container = container;
    this.form = this.container.find('#new_user');
    SigninForm.__super__.constructor.call(this, this.container, this.form);
  }

  SigninForm.prototype.bindEvents = function() {
    return SigninForm.__super__.bindEvents.apply(this, arguments);
  };

  return SigninForm;
}(ModalForm);

module.exports = SigninForm;
