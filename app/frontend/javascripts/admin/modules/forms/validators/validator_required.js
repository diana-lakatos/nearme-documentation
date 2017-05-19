import Validator from './validator';
const toString = require('lodash/toString');

class ValidatorRequired extends Validator {
  _sanitize(value) {
    if (Array.isArray(value)) {
      value = value.filter(o => !!o).join(',');
    }
    value = toString(value);

    return value.trim();
  }

  run(value) {
    this._prepareRun();

    value = this._sanitize(value);
    if (value === '') {
      this._setError('* Required');
    }

    return this.isValid();
  }
}

module.exports = ValidatorRequired;
