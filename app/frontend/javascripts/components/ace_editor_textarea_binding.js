/* global require, $, module */
'use strict';

var ace = require('brace');
require('brace/mode/javascript');
require('brace/mode/html');
require('brace/mode/css');
require('brace/mode/liquid');
require('brace/theme/xcode');
require('brace/ext/searchbox');

// Hook up ACE editor to all textareas with data-editor attribute
module.exports = function(textarea) {
  textarea = $(textarea);

  var mode = textarea.data('editor');

  var editDiv = $('<div>', {
    css: { position: 'absolute', width: textarea.width(), height: textarea.height() },
    'class': textarea.attr('class')
  }).insertBefore(textarea);

  textarea.css('visibility', 'hidden');

  var editor = ace.edit(editDiv[0]);
  editor.renderer.setShowGutter(true);
  editor.getSession().setTabSize(2);
  editor.getSession().setUseSoftTabs(true);
  editor.setShowPrintMargin(false);
  editor.getSession().setValue(textarea.val());
  editor.getSession().setMode('ace/mode/' + mode);
  editor.setTheme('ace/theme/xcode');

  // copy back to textarea on form submit...
  textarea.closest('form').submit(function() {
    textarea.val(editor.getSession().getValue());
  });
};
