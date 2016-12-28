import SyntaxParser from 'syntax_parser';

class SyntaxParserHTMLMixed extends SyntaxParser {
  constructor() {
    super();
  }

  parse(code) {
    return code;
  }
}

module.exports = SyntaxParserHTMLMixed;
