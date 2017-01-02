import 'codemirror/lib/codemirror.css';
import 'codemirror/theme/base16-light.css';

import 'codemirror/addon/edit/closebrackets';
import 'codemirror/addon/edit/closetag';
import 'codemirror/addon/edit/matchtags';
import 'codemirror/addon/edit/matchbrackets';

import 'codemirror/addon/fold/foldcode';
import 'codemirror/addon/fold/foldgutter.js';
import 'codemirror/addon/fold/foldgutter.css';
import 'codemirror/addon/fold/brace-fold';
import 'codemirror/addon/fold/xml-fold';
import 'codemirror/addon/fold/markdown-fold';
import 'codemirror/addon/fold/comment-fold';

import 'codemirror/addon/search/searchcursor';
import 'codemirror/addon/search/search';

import 'codemirror/addon/dialog/dialog.js';
import 'codemirror/addon/dialog/dialog.css';

import 'codemirror/addon/display/fullscreen.css';
import 'codemirror/addon/display/fullscreen.js';
import 'codemirror/addon/display/placeholder';

import 'codemirror/addon/comment/comment';

import 'codemirror/addon/selection/active-line';

import 'codemirror/keymap/sublime';

import 'codemirror/mode/javascript/javascript';
import 'codemirror/mode/css/css';
import 'codemirror/mode/htmlmixed/htmlmixed';
import 'codemirror/mode/markdown/markdown';
import 'codemirror/mode/liquid/liquid';

module.exports = {
  lineNumbers: true,
  theme: 'base16-light',
  styleActiveLine: true,
  autoCloseBrackets: true,
  autoCloseTags: true,
  foldGutter: true,
  showCursorWhenSelecting: true,
  matchTags: true,
  keyMap: 'sublime',
  gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
  extraKeys: {
    'Esc': function(cm) {
      cm.setOption('fullScreen', !cm.getOption('fullScreen'));
    },
    'Ctrl-J': 'toMatchingTag'
  }
};

