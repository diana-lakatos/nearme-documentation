import Validator from './validator';

class ValidatorEmail extends Validator {
  run(value) {
    this._prepareRun();

    var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

    if (re.test(value) === false) {
      this._setError('Invalid email');
    }

    return this.isValid();
  }
}

module.exports = ValidatorEmail;
