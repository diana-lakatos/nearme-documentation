class Validator {
  constructor() {
    if (new.target === Validator) {
      throw new TypeError('Cannot construct Validator class directly');
    }

    if (this.run === undefined) {
      throw new TypeError('Must implement run method');
    }

    this._error = null;
  }

  getError() {
    return this._error;
  }

  isValid() {
    return this._error === null;
  }

  _prepareRun() {
    this._error = null;
  }

  _setError(error) {
    this._error = error;
  }
}

module.exports = Validator;
