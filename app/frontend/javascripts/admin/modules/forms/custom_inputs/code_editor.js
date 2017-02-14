const Events = require('minivents/dist/minivents.commonjs');

const CodeMirror = require('codemirror/lib/codemirror');
const editorDefaults = require('./codemirror/defaults');

class CodeEditor {
  constructor(input, syntax = 'text', editorOptions = {}) {
    new Events(this);
    this._input = input;
    this._syntax = syntax;

    this._editorOptions = Object.assign({}, editorDefaults, editorOptions);
    this._editorOptions.mode = this._syntax;

    this._initEditor();
    this._bindEvents();
  }

  _initEditor(){
    this._editor = CodeMirror.fromTextArea(this._input, this._editorOptions);
    this._input.editor = this;
  }

  _bindEvents() {
    this._editor.on('change', ()=>{
      this.emit('change');
    });

    this._editor.on('blur', ()=>{
      this._editor.save();
    });
  }

  getSyntax() {
    return this._syntax;
  }

  getValue() {
    return this._editor.getValue();
  }

  setValue(value) {
    this._editor.setValue(value);
    this._editor.save();
  }

  static getInstanceFromTextarea(textarea) {
    return textarea.editor;
  }
}

module.exports = CodeEditor;
