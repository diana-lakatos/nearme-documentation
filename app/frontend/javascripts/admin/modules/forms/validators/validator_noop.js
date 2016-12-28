import Validator from './validator';

class ValidatorNoop extends Validator {
  run(){
    return true;
  }
}

module.exports = ValidatorNoop;
