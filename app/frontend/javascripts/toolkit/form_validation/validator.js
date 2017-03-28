// @flow

const DEFAULT_MESSAGE = 'Invalid value';

class Validator {
  message: ?string;
  condition: (boolean | () => boolean);

  constructor(message: ?string, condition: (boolean | () => boolean) = true) {
    if (message) {
      this.setMessage(message);
    }

    this.condition = condition;
  }

  setMessage(message: string) {
    this.message = message;
  }

  setCondition(condition: (boolean | () => boolean)) {
    this.condition = condition;
  }

  getMessage(): string {
    return this.message || this.defaultMessage();
  }

  defaultMessage(): string {
    return DEFAULT_MESSAGE;
  }

  checkConditionalRun(): boolean {
    if (typeof this.condition === 'function') {
      return this.condition();
    }
    return this.condition;
  }

  process(value: string): Promise<mixed> {
    /* Condition for running validation not met, resulting resolved promise */
    if (this.checkConditionalRun() === false) {
      return Promise.resolve();
    }

    return this.run(value);
  }

  run(value: string): Promise<mixed> {
    throw new TypeError(`Validator class should not be used directly. Passed ${value}`);
  }
}

module.exports = Validator;
