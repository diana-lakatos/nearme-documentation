const Events = require('minivents/dist/minivents.commonjs');

class UserEntryEditAction {
  constructor(trigger, container) {
    new Events(this);

    this.trigger = trigger;

    this.target = container.querySelector('.entry-content-a');
    this.container = container;

    if (!this.target) {
      return;
    }

    this.bindEvents();
  }

  bindEvents() {
    this.trigger.addEventListener('click', (e) => {
      e.preventDefault();
      this.toggleEditor();
    });
  }

  toggleEditor() {
    this.emit('toggle');
    if (this.target.classList.contains('is-active')) {
      this.hideEditor();
      return;
    }
    this.showEditor();
  }

  hideEditor() {
    this.target.classList.remove('is-active');
  }

  showEditor() {
    this.target.classList.add('is-active');
    this.target.querySelector('textarea').focus();
  }

}

module.exports = UserEntryEditAction;
