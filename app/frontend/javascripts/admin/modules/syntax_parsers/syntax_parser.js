class SyntaxParser {
  constructor() {
    if (typeof this.parse !== 'function') {
      throw new TypeError('Syntax parser must implement getParsed() method');
    }
  }
}

module.exports = SyntaxParser;
