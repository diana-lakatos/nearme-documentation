var Modal,
  ModalForm,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

Modal = require('./modal');

ModalForm = function() {
  function ModalForm(container, form) {
    this.container = container;
    this.form = form != null ? form : this.container;
    this.insideModal = bind(this.insideModal, this);
    this.updateModalOnSubmit = bind(this.updateModalOnSubmit, this);
    this.focusInput = bind(this.focusInput, this);
    this.focusInput();
    this.bindEvents();
    if (this.insideModal()) {
      this.updateModalOnSubmit();
    }
  }

  ModalForm.prototype.focusInput = function() {
    if (this.form.find('.error-block').length > 0) {
      return this.form.find('.error-block').eq(0).siblings('input:visible').focus();
    } else {
      return this.form.find('input:visible').eq(0).focus();
    }
  };

  ModalForm.prototype.bindEvents = function() {};

  ModalForm.prototype.updateModalOnSubmit = function() {
    return this.form.submit(
      function(_this) {
        return function() {
          Modal.load({
            type: 'POST',
            url: _this.form.attr('action'),
            data: _this.form.serialize()
          });
          return false;
        };
      }(this)
    );
  };

  ModalForm.prototype.insideModal = function() {
    return this.container.closest('.modal-container.visible').length > 0;
  };

  return ModalForm;
}();

module.exports = ModalForm;
