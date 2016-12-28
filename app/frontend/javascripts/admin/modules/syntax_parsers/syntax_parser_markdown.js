import SyntaxParser from 'syntax_parser';
const markdown = require('markdown/lib/markdown');

class SyntaxParserMarkdown extends SyntaxParser {
  constructor() {
    super();
  }

  parse(code) {
    return markdown.toHTML(code);
  }
}

module.exports = SyntaxParserMarkdown;
