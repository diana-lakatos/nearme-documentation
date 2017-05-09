const INACTIVE_CLASS = 'hidden';

class LimitedInput {
  constructor(input) {
    if (
      !(input instanceof HTMLInputElement) &&
      !(input instanceof HTMLTextAreaElement)
    ) {
      console.log(input);
      throw new Error('Invalid or missing input for LimitedInput');
    }
    this.input = input;
    this.limit = parseInt(input.dataset.counterLimit, 10);
    // fail whether it's NaN or 0
    if (!this.limit) {
      throw new Error('Character limit not set on limited input');
    }

    this.showAfterLimit =
      parseInt(this.input.dataset.counterShowAfter, 10) || 0;

    this.info = this.getInfoElement();

    this.labels = {
      few: this.info.dataset.labelFew || '%{count} characters left',
      one: this.info.dataset.labelOne || '1 character left',
      zero: this.info.dataset.labelZero || '0 characters left'
    };

    this.bindEvents();
    this.updateLimiter();
  }

  getInfoElement() {
    let existing = this.input.parentNode.querySelector('[data-counter-for]');
    if (existing) {
      return existing;
    }

    let el = document.createElement('p');
    el.classList.add('help-block', 'limiter');
    this.input.insertAdjacentElement('afterend', el);

    return el;
  }

  bindEvents() {
    this.input.addEventListener('keyup', this.updateLimiter.bind(this));
    this.input.addEventListener('focus', this.updateLimiter.bind(this));
  }

  updateLimiter() {
    let text = this.input.value;
    // new line character is treated as a 2 characters in textarea, that's why we use 'aa'
    let chars = text.replace(/\n/g, 'aa').length;

    if (chars >= this.showAfterLimit) {
      this.info.classList.remove(INACTIVE_CLASS);
    } else {
      this.info.classList.add(INACTIVE_CLASS);
    }

    if (chars > this.limit) {
      this.input.value = text.substr(0, this.limit);
      chars = this.limit;
    }

    let leftChars = this.limit - chars;

    if (leftChars === 0) {
      this.info.innerHTML = this.labels.zero;
      return;
    }

    if (leftChars === 1) {
      this.info.innerHTML = this.labels.one;
      return;
    }

    this.info.innerHTML = this.labels.few.replace('%{count}', leftChars);
  }
}

module.exports = LimitedInput;
