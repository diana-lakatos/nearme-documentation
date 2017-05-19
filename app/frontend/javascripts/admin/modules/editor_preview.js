class EditorPreview {
  constructor(editor, preview) {
    this._editor = editor;
    this._preview = preview;

    if (this._editor.getSyntax() === 'markdown') {
      require.ensure('syntax_parsers/syntax_parser_markdown', require => {
        let SyntaxParserMarkdown = require('syntax_parsers/syntax_parser_markdown');
        this._parser = new SyntaxParserMarkdown();
        this._bindEvents();
        this._updatePreview();
      });
    } else if (this._editor.getSyntax() === 'htmlmixed') {
      require.ensure('syntax_parsers/syntax_parser_htmlmixed', require => {
        let SyntaxParserHTMLMixed = require('syntax_parsers/syntax_parser_htmlmixed');
        this._parser = new SyntaxParserHTMLMixed();
        this._bindEvents();
        this._updatePreview();
      });
    } else {
      throw new Error(`${this._editor.getSyntax()} mode is not supported in EditorPreview`);
    }
  }

  _bindEvents() {
    this._editor.on('change', this._updatePreview.bind(this));
  }

  _updatePreview() {
    this._preview.innerHTML = this._parser.parse(this._editor.getValue());
  }
}

module.exports = EditorPreview;
