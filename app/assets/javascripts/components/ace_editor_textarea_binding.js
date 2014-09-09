// Hook up ACE editor to all textareas with data-editor attribute
$(function () {
  $('textarea[data-editor]').each(function () {
      var textarea = $(this);

      var mode = textarea.data('editor');

      var editDiv = $('<div>', {
        position: 'absolute',
        width: textarea.width(),
        height: textarea.height(),
        'class': textarea.attr('class')
      }).insertBefore(textarea);

      textarea.css('visibility', 'hidden');

      var editor = ace.edit(editDiv[0]);
      editor.renderer.setShowGutter(true);
      editor.getSession().setTabSize(2);
      editor.getSession().setUseSoftTabs(true);
      editor.setShowPrintMargin(false);
      editor.getSession().setValue(textarea.val());
      editor.getSession().setMode("ace/mode/" + mode);
      editor.setTheme("ace/theme/xcode");

      // copy back to textarea on form submit...
      textarea.closest('form').submit(function () {
          textarea.val(editor.getSession().getValue());
      })
    });
});
