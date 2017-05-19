var Forms;

Forms = function() {
  function Forms() {}

  /*
   * updates placeholder class on selects
   */
  Forms.placeholders = function() {
    return $('select').on('change.placeholder', function() {
      return $(this).toggleClass('placeholder', !$(this).val());
    }).triggerHandler('change.placeholder');
  };

  /*
   * zooms out to full page once you leave input control
   */
  Forms.blurZoomOut = function() {
    var viewport;
    viewport = $('meta[name=viewport]');
    return $('input, textarea, select').on('blur', function(event) {
      event.preventDefault();
      viewport.attr('content', 'width=device-width, initial-scale=1.0, maximum-scale=1');
      return setTimeout(
        function() {
          return viewport.attr('content', 'width=device-width, initial-scale=1.0');
        },
        50
      );
    });
  };

  /*
   * placeholders and checking empty on file inputs
   */
  Forms.fileInputs = function() {
    var inputs;
    inputs = $('.file-a input');
    inputs.on('change', function() {
      var $input, value;
      $input = $(this);
      value = $input.val();
      $input.parent().toggleClass('is-empty', value === '');
      if (value === '') {
        value = $input.attr('placeholder');
      }
      return $input.next('span').html(value);
    });
    return inputs.each(function() {
      $(this).parent().toggleClass('is-empty', $(this).val() === '');
      $(this).after('<span/>').triggerHandler('change');
    });
  };

  Forms.linkImages = function() {
    var inputs, trimFileName;
    inputs = $('.links-group .control-group.file input');
    inputs.each(function() {
      return $(this).data('empty-label', $(this).attr('data-upload-label'));
    });
    trimFileName = function(str) {
      return str.replace('C:\\fakepath\\', '');
    };
    return inputs.on('change', function() {
      var label;
      label = $(this).val() ? trimFileName($(this).val()) : $(this).data('empty-label');
      return $(this).closest('.control-group.file').attr('data-upload-label', label);
    });
  };

  /*
   * selectize plugin
   */
  Forms.selectize = function() {
    if (!($.fn.selectize && !Modernizr.touch)) {
      return;
    }
    return $('select.selectize').each(function() {
      var $select, select;
      select = this;
      $select = $(this);
      $select.selectize({
        plugins: [ 'remove_button' ],
        hideSelected: false,
        closeAfterSelect: !$select.is('[multiple]'),
        onChange: function() {
          var event;
          event = new Event('change', { 'view': window, 'bubbles': true, 'cancellable': true });
          return !select.dispatchEvent(event);
        }
      });
      return $select.on('change', function() {
        if ($select.val() === 0) {
          return $select.val('');
        }
      });
    });
  };

  Forms.initialize = function() {
    this.placeholders();
    this.blurZoomOut();
    this.fileInputs();
    this.linkImages();
    return this.selectize();
  };

  return Forms;
}();

module.exports = Forms;
