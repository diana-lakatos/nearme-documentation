import Validator from './validator';

class ValidatorUrl extends Validator {
  run(value) {
    this._prepareRun();

    var re = /#\b(([\w-]+:\/\/?|www[.])[^\s()<>]+(?:\([\w\d]+\)|([^[:punct:]\s]|\/)))#iS/;

    if (re.test(value) === false) {
      this._setError('Invalid URL');
    }

    return this.isValid();
  }
}

module.exports = ValidatorUrl;
