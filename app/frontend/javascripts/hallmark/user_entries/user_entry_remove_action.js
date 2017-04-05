// @flow
//
class UserEntryRemoveAction {
  trigger: HTMLElement;
  container: HTMLElement;
  confirmLabel: string;
  actionUrl: string;

  constructor(trigger: HTMLElement, container: HTMLElement) {

    this.trigger = trigger;
    this.container = container;
    this.confirmLabel = this.trigger.dataset.confirmLabel || 'Are you sure you want to remove this element?';
    let actionUrl = this.trigger.getAttribute('href');
    if (!actionUrl) {
      throw new Error('Missing actionURL attribute for remove action');
    }
    this.actionUrl = actionUrl;

    this.bindEvents();
  }

  bindEvents() {
    this.trigger.addEventListener('click', (e: Event) => {
      e.preventDefault();
      if (this.confirm()) {
        this.removeContainer();
      }
    });
  }

  confirm(): boolean {
    return confirm(this.confirmLabel);
  }

  removeContainer() {
    this.container.classList.add('hidden');

    $.ajax({
      url: this.actionUrl,
      method: 'delete',
      dataType: 'json'
    }).done(() => {
      if (this.container.parentNode) {
        this.container.parentNode.removeChild(this.container);
      }
    }).fail(() => {
      alert('We were unable to remove this entry. Please, try again');
      this.container.classList.remove('hidden');
      throw new Error(`Unable to remove actionable entry from ${this.actionUrl}`);
    });
  }
}

module.exports = UserEntryRemoveAction;
