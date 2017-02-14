'use strict';

let CodeMirror = require('codemirror/lib/codemirror');
require('codemirror/addon/mode/overlay');

CodeMirror.defineMode('liquid', function(config, parserConfig) {
  var liquidOverlay = {
    token: function(stream) {
      var ch;
            /* Variables. */
      if (stream.match('{{')) {
        ch = stream.next();
        while (ch !== null) {
          if (ch == '}' && stream.next() == '}') {
            break;
          }
          ch = stream.next();
        }
        return 'liquid-variable';
      }

            /* Tags. */
      if(stream.match('{%')) {
        ch = stream.next();
        while (ch !== null) {
          if (ch == '%' && stream.next() == '}') {
            break;
          }

          ch = stream.next();
        }
        return 'liquid-tag';
      }

      while (stream.next() != null && !stream.match('{{', false) && !stream.match('{%', false)) {
        continue;
      }
      return null;
    }
  };
  return CodeMirror.overlayMode(CodeMirror.getMode(config, parserConfig.backdrop || 'text/html'), liquidOverlay);
});
