const closest = require('../toolbox/closest');
const UserEntryRemoveAction = require('./user_entry_remove_action');
const UserEntryEditAction = require('./user_entry_edit_action');
const UserEntryReportSpamAction = require('./user_entry_report_spam_action');
const Gallery = require('../gallery/gallery');

class UserEntry {
  constructor(container) {
    this.ui = {};
    this.bound = {};

    this.ui.container = container;
    if (this.ui.container.dataset.userEntryInitialized) {
      return;
    }
    this.ui.container.dataset.userEntryInitialized = true;

    this.creatorId = parseInt(container.dataset.creatorId, 10);
    this.currentUserId = parseInt(document.body.dataset.cid, 10);
    this.actionsActive = false;

    if (!this.currentUserId) {
      return;
    }

    this.ui.actions = this.ui.container.querySelector('.entry-actions-a');
    this.actionsContainerId = this.ui.actions.id;
    this.ui.actionsToggler = this.ui.container.querySelector('.entry-actions-a > button');
    this.editAction = new UserEntryEditAction(this.ui.actions.querySelector('[data-edit-entry]'), this.ui.container);
    this.removeAction = new UserEntryRemoveAction(this.ui.actions.querySelector('[data-remove-entry]'), this.ui.container);
    this.reportSpamAction = new UserEntryReportSpamAction(this.ui.actions.querySelector('[data-report-spam]'), this.ui.container);

    this.initGallery();

    this.bound.detectBodyClick = this.detectBodyClick.bind(this);

    this.bindEvents();
    this.initialize();
  }

  bindEvents() {
    this.ui.actionsToggler.addEventListener('click', (e) => {
      if (e.defaultPrevented) {
        return;
      }
      e.preventDefault();
      this.toggleActions();
    });

    this.editAction.on('toggle', () => {
      this.hideActions();
    });

    this.ui.container.addEventListener('click', (e) => {
      if (closest(e.target, '[data-cancel-edit]')) {
        e.preventDefault();
        this.editAction.hideEditor();
      }
    });

    $(this.ui.container).on('update', () => {
      this.initGallery();
    });
  }

  initGallery() {
    let container = this.ui.container.querySelector('[data-entry-images]');
    if (!container) {
      return;
    }
    new Gallery(container);
  }


  toggleActions() {
    if (this.actionsActive) {
      return this.hideActions();
    }

    this.showActions();
  }

  showActions() {
    this.ui.actions.classList.add('actions--active');
    this.actionsActive = true;
    document.body.addEventListener('click', this.bound.detectBodyClick);
  }

  hideActions() {
    this.ui.actions.classList.remove('actions--active');
    this.actionsActive = false;
    document.body.removeEventListener('click', this.bound.detectBodyClick);
  }

  detectBodyClick(e) {
    if (closest(e.target, `#${this.actionsContainerId}`) === null) {
      this.hideActions();
    }
  }

  initialize() {
    if (this.creatorId === this.currentUserId) {
      this.ui.container.classList.add('current-user-is-owner');
    }
  }
}

module.exports = UserEntry;
