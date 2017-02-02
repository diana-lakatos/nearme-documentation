class UserEntryRemoveAction {
  constructor(trigger, container) {
    this.ui = {};
    this.ui.trigger = trigger;
    this.ui.container = container;
    this.confirmLabel = this.ui.trigger.dataset.confirmLabel;
    this.actionUrl = this.ui.trigger.getAttribute('href');

    this.bindEvents();
  }

  bindEvents() {
    this.ui.trigger.addEventListener('click', (e) => {
      e.preventDefault();
      if (this.confirm()) {
        this.removeContainer();
      }
    });
  }

  confirm() {
    return confirm(this.confirmLabel);
  }

  removeContainer() {
    this.ui.container.classList.add('hidden');

    $.ajax({
      url: this.actionUrl,
      method: 'delete',
      dataType: 'json'
    }).done(() => {
      this.ui.container.parentNode.removeChild(this.ui.container);
    }).fail(() => {
      alert('We were unable to remove this entry. Please, try again');
      this.ui.container.classList.remove('hidden');
      throw new Error(`Unable to remove actionable entry from ${this.actionUrl}`);
    });
  }
}

module.exports = UserEntryRemoveAction;
