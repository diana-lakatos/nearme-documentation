var SetupNestedForm;

SetupNestedForm = function() {
  function SetupNestedForm(form) {
    this.form = form;
  }

  SetupNestedForm.prototype.setup = function(
    removeLink,
    hiddenField,
    removeField,
    wrapper,
    newLink,
    setupUploadObligation
  ) {
    var hiddenElement, i, j, len, len1, ref, ref1, removeElement;
    if (setupUploadObligation == null) {
      setupUploadObligation = false;
    }
    this.form.find(removeLink).removeClass('hidden');
    ref = this.form.find(hiddenField);
    for (i = 0, len = ref.length; i < len; i++) {
      hiddenElement = ref[i];
      if ($(hiddenElement).prop('checked')) {
        $(hiddenElement).parents(wrapper).hide();
      }
    }
    this.form.find(hiddenField).change(function() {
      if ($(this).prop('checked')) {
        return $(this).parents(wrapper).hide('slow');
      } else {
        return $(this).parents(wrapper).show('slow');
      }
    });
    ref1 = this.form.find(removeField);
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      removeElement = ref1[j];
      if ($(removeElement).prop('checked')) {
        $(removeElement).parents(wrapper).hide();
      }
    }
    this.form.find(removeField).change(function() {
      if ($(this).prop('checked')) {
        return $(this).parents(wrapper).hide('slow');
      }
    });
    this.form.find(newLink).click(
      function(_this) {
        return function() {
          _this.form.find(hiddenField + ':checked').eq(0).prop('checked', false).trigger('change');
          if (_this.form.find(hiddenField + ':checked').length === 0) {
            return _this.form.find(newLink).hide();
          }
        };
      }(this)
    );
    if (setupUploadObligation) {
      return this.form.find('.document-requirements input[type="radio"]').change(
        function(_this) {
          return function(e) {
            var k, l, len2, len3, ref2, ref3;
            if ($(e.currentTarget).val() === 'Not Required') {
              ref2 = _this.form.find(hiddenField);
              for (k = 0, len2 = ref2.length; k < len2; k++) {
                hiddenElement = ref2[k];
                if ($(hiddenElement).parents(wrapper).is(':visible')) {
                  $(hiddenElement).data('hide', true);
                  $(hiddenElement).prop('checked', true);
                }
              }
              return _this.form
                .find('.document-requirements .document-requirements-fields')
                .hide('slow');
            } else {
              ref3 = _this.form.find(hiddenField);
              for (l = 0, len3 = ref3.length; l < len3; l++) {
                hiddenElement = ref3[l];
                if ($(hiddenElement).data('hide')) {
                  $(hiddenElement).prop('checked', false);
                  $(hiddenElement).removeData('hide');
                }
              }
              _this.form
                .find('.document-requirements .document-requirements-fields')
                .removeClass('hidden');
              return _this.form
                .find('.document-requirements .document-requirements-fields')
                .show('slow');
            }
          };
        }(this)
      );
    }
  };

  return SetupNestedForm;
}();

module.exports = SetupNestedForm;
