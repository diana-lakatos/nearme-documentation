var selects;

require('selectize/dist/js/selectize');

selects = function(context) {
  if (context == null) {
    context = 'body';
  }
  return $(context).find('.form-group select:not(.customSelect)').each(function() {
    var options, select, selectizeInstance;
    select = this;
    options = {
      onInitialize: function() {
        var s;
        s = this;
        return this.revertSettings.$children.each(function() {
          return $.extend(s.options[this.value], $(this).data());
        });
      },
      onChange: function() {
        var event;
        event = new Event('change', { 'view': window, 'bubbles': true, 'cancellable': true });
        return select.dispatchEvent(event);
      }
    };
    if ($(this).attr('multiple')) {
      options.plugins = [ 'remove_button' ];
    }
    options.allowEmptyOption = !!$(this).data('allow-empty-option');
    $(document).trigger('plugin:loaded.selectize');
    selectizeInstance = $(this).selectize(options)[0].selectize;
    return selectizeInstance.enable();
  });
};

module.exports = selects;
