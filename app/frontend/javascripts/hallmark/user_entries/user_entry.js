// @flow

const ACTIONS_SELECTOR = '.entry-actions-a';
const ACTIONS_TOGGLER_SELECTOR = '.entry-actions-a > button';
const EDIT_ACTION_SELECTOR = '[data-edit-entry]';
const REMOVE_ACTION_SELECTOR = '[data-remove-entry]';
const REPORT_SPAM_ACTION_SELECTOR = '[data-report-spam]';
const GALLERY_SELECTOR = '[data-entry-images]';

const ACTIONS_ACTIVE_CLASS = 'actions--active';
const CURRENT_USER_OWNER_CLASS = 'current-user-is-owner';

import { closest, findElement } from '../../toolkit/dom';
import UserEntryRemoveAction from './user_entry_remove_action';
import UserEntryEditAction from './user_entry_edit_action';
import UserEntryReportSpamAction from './user_entry_report_spam_action';
import Gallery from '../gallery/gallery';

class UserEntry {
  container: HTMLElement;
  creatorId: number;
  currentUserId: number;
  actionsActive: boolean;
  actions: HTMLElement;
  actionsContainerId: string;
  actionsToggler: HTMLElement;
  body: HTMLElement;

  editAction: UserEntryEditAction;
  removeAction: UserEntryRemoveAction;
  reportSpamAction: UserEntryReportSpamAction;

  boundDetectBodyClick: (event: Event) => void;

  constructor(container: HTMLElement) {
    this.container = container;

    if (this.container.dataset.userEntryInitialized) {
      return;
    }
    this.container.dataset.userEntryInitialized = 'true';

    let creatorId = parseInt(container.dataset.creatorId, 10);
    if (!creatorId || isNaN(creatorId)) {
      throw new Error('Unable to set creator ID');
    }

    this.creatorId = creatorId;

    let body = document.querySelector('body');
    if (!body) {
      throw new Error('Invalid context, body not found');
    }
    this.body = body;

    let currentUserId = parseInt(body.dataset.cid, 10);
    if (!currentUserId || isNaN(currentUserId)) {
      throw new Error('Uanble to get current user id');
    }

    this.currentUserId = currentUserId;
    this.actionsActive = false;

    this.actions = findElement(ACTIONS_SELECTOR, this.container);
    let actionsContainerId = this.actions.getAttribute('id');
    if (!actionsContainerId) {
      throw new Error('Actions container is missing ID attribute');
    }
    this.actionsContainerId = actionsContainerId;

    this.actionsToggler = findElement(ACTIONS_TOGGLER_SELECTOR, this.container);
    this.editAction = new UserEntryEditAction(
      findElement(EDIT_ACTION_SELECTOR, this.container),
      this.container
    );
    this.removeAction = new UserEntryRemoveAction(
      findElement(REMOVE_ACTION_SELECTOR, this.container),
      this.container
    );
    this.reportSpamAction = new UserEntryReportSpamAction(
      findElement(REPORT_SPAM_ACTION_SELECTOR, this.container),
      this.container
    );

    this.initGallery();

    this.boundDetectBodyClick = this.detectBodyClick.bind(this);

    this.bindEvents();
    this.initialize();
  }

  bindEvents() {
    this.actionsToggler.addEventListener('click', (e: Event) => {
      if (e.defaultPrevented) {
        return;
      }
      e.preventDefault();
      this.toggleActions();
    });

    this.editAction.on('toggle', () => {
      this.hideActions();
    });

    this.container.addEventListener('click', (e: Event) => {
      if (closest(e.target, '[data-cancel-edit]')) {
        e.preventDefault();
        this.editAction.hideEditor();
      }
    });

    jQuery(this.container).on('update', () => {
      this.initGallery();
    });
  }

  initGallery() {
    let container = this.container.querySelector(GALLERY_SELECTOR);
    if (!container) {
      return;
    }
    new Gallery(container);
  }

  toggleActions() {
    if (this.actionsActive) {
      this.hideActions();
      return;
    }

    this.showActions();
  }

  showActions() {
    this.actions.classList.add(ACTIONS_ACTIVE_CLASS);
    this.actionsActive = true;
    this.body.addEventListener('click', this.boundDetectBodyClick);
  }

  hideActions() {
    this.actions.classList.remove(ACTIONS_ACTIVE_CLASS);
    this.actionsActive = false;
    this.body.removeEventListener('click', this.boundDetectBodyClick);
  }

  detectBodyClick(event: Event) {
    let container = closest(event.target, `#${this.actionsContainerId}`);
    if (container === null) {
      this.hideActions();
    }
  }

  initialize() {
    if (this.creatorId === this.currentUserId) {
      this.container.classList.add(CURRENT_USER_OWNER_CLASS);
    }
  }
}

module.exports = UserEntry;
