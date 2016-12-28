import Validator from './validator';

class ValidatorFloat extends Validator {

  _isFloat(value) {
    return !isNaN(parseFloat(value)) && isFinite(value);
  }

  run(value){
    this._prepareRun();

    if (this._isFloat(value) === false) {
      this._setError('Not a valid number');
    }

    return this.isValid();
  }
}

module.exports = ValidatorFloat;
