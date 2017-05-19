import Validator from './validator';

class ValidatorDateTime extends Validator {
  run(value) {
    this._prepareRun();

    if (isNaN(Date.parse(value))) {
      this._setError('Not a valid date');
    }

    return this.isValid();
  }
}

module.exports = ValidatorDateTime;
