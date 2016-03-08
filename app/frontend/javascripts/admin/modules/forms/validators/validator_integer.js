import Validator from './validator';

class ValidatorInteger extends Validator {

  _isInteger(value) {
    return !isNaN(value) && parseInt(Number(value)) == value && !isNaN(parseInt(value, 10));
  }

  run(value){
    this._prepareRun();

    if (this._isInteger(value) === false) {
      this._setError('Not an integer');
    }

    return this.isValid();
  }
}

module.exports = ValidatorInteger;
