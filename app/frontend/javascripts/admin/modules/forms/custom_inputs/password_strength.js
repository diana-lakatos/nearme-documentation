var zxcvbn = require('zxcvbn');
import closest from '../../../toolkit/closest';

var strengthLabels = {
  0: 'Worst',
  1: 'Bad',
  2: 'Weak',
  3: 'Good',
  4: 'Strong'
};

class PasswordStrength {
  constructor(toggler) {
    this._ui = {};
    this._ui.toggler = toggler;
    this._ui.wrapper = closest(this._ui.toggler, '.form-group');
    this._ui.password = this._ui.wrapper.querySelector('input');

    this.build();
    this.bindEvents();
  }

  build(){
    this._ui.meter = document.createElement('meter');
    this._ui.meter.setAttribute('max', 4);
    this._ui.meter.classList.add('strength-meter');
    this._ui.wrapper.appendChild(this._ui.meter);

    this._ui.infobox = document.createElement('p');
    this._ui.infobox.classList.add('password-strength-text');
    this._ui.wrapper.appendChild(this._ui.infobox);
  }

  bindEvents(){
    this._ui.password.addEventListener('input', this.verifyPasswordStrength.bind(this));
    this._ui.toggler.addEventListener('click', this.toggleFieldType.bind(this));
  }

  verifyPasswordStrength(){
    let val = this._ui.password.value;
    let result = zxcvbn(val);

        /* Update the password strength meter */
    this._ui.meter.value = result.score;

        /* Update text indicator */
    if (val !== '') {
      this._ui.infobox.innerHTML = `Strength: <b>${strengthLabels[result.score]}</b>`;
    }
    else {
      this._ui.infobox.innerHTML = '';
    }
  }

  toggleFieldType(){
    this._ui.password.type = this._ui.password.type === 'password' ? 'text' : 'password';
    this._ui.wrapper.dataset.passwordMode = this._ui.password.type;
  }
}

module.exports = PasswordStrength;
