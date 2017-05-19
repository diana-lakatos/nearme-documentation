var DraftValidationController,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

DraftValidationController = function() {
  function DraftValidationController(form) {
    this.submitDraftOnChange = bind(this.submitDraftOnChange, this);
    this.bindEvents = bind(this.bindEvents, this);
    this.form = $(form);
    this.bindEvents();
    this.formMethod = this.form.find('input[name="_method"]').val();
    this.formAction = this.form.attr('action');
  }

  DraftValidationController.prototype.bindEvents = function() {
    return this.submitDraftOnChange();
  };

  DraftValidationController.prototype.submitDraftOnChange = function() {
    if (this.form.find('[data-autosave-draft]').length === 0) {
      return false;
    }
    if (this.form.find('input[type="submit"]:disabled').length > 0) {
      return false;
    }
    return this.form.find('input, textarea').change(
      function(_this) {
        return function(event) {
          var field, method;
          field = $(event.target);
          if (_this.formMethod === 'PATCH') {
            method = 'PUT';
          } else {
            method = 'POST';
          }
          $.ajax({
            type: method,
            url: _this.formAction,
            data: _this.form.serialize() + '&save_draft=true&save_as_draft=true',
            dataType: 'JSON',
            cache: false,
            error: _this.handleAjaxError,
            success: _this.handleAjaxSuccess(field)
          });
          return true;
        };
      }(this)
    );
  };

  DraftValidationController.prototype.handleAjaxSuccess = function(field) {
    var icon;
    icon = $(
      '<span class="fa fa-check" style="color:green; position:absolute; right: 1px" aria-hidden="true"></span>'
    );
    field.parents('.control-group, .form-group').append(icon).css('position', 'relative');
    return icon.delay(1000).fadeOut();
  };

  return DraftValidationController;
}();

module.exports = DraftValidationController;
