// @flow
let resolver = require('./spam_report_resolver');

type ActionType = {
  url: string,
  label: string,
  method: 'delete' | 'post'
};

type SpamReportDataType = {
  comments_spam_reports: Array<number>,
  events_spam_reports: Array<number>
};

class UserEntryReportSpamAction {

  trigger: HTMLElement;
  container: HTMLElement;
  raportExists: boolean;
  type: 'comment' | 'event'
  entryId: number;
  actionCancel: ActionType;
  actionCreate: ActionType;
  processing: boolean;

  data: SpamReportDataType;

  constructor(trigger: HTMLElement, container: HTMLElement) {
    this.trigger = trigger;
    this.raportExists = false;
    this.type = container.dataset.commentId ? 'comment' : 'event';
    this.processing = false;

    let entryId = container.dataset.commentId ? container.dataset.commentId : container.dataset.activityFeedEventId;
    entryId = parseInt(entryId, 10);
    if (!entryId || isNaN(entryId)) {
      throw new Error('Unable to determine entry ID in spam report action');
    }
    this.entryId = entryId;

    let cancelReportUrl = trigger.dataset.cancelReportUrl;
    let cancelReportLabel = trigger.dataset.cancelReportLabel;
    let createReportUrl = trigger.getAttribute('href');
    let createReportLabel = trigger.innerHTML;

    if (!cancelReportUrl) {
      throw new Error('Missing cancel report url');
    }
    if (!cancelReportLabel) {
      throw new Error('Missing cancel report label');
    }

    if (!createReportUrl) {
      throw new Error('Missing create report url');
    }
    if (!createReportLabel) {
      throw new Error('Missing create report label');
    }

    this.actionCancel = {
      url: cancelReportUrl,
      label: cancelReportLabel,
      method: 'delete'
    };

    this.actionCreate = {
      url: createReportUrl,
      label: createReportLabel,
      method: 'post'
    };

    this.container = container;

    resolver.get().then((data: SpamReportDataType) => {
      this.data = data;
      this.initialize();
    });

    this.bindEvents();
  }

  initialize() {
    let spamReports = this.data[`${this.type}s_spam_reports`];

    if (spamReports.indexOf(this.entryId) > -1) {
      this.raportExists = true;
      this.updateTrigger();
    }
  }

  bindEvents() {
    this.trigger.addEventListener('click', (e: Event) => {
      e.preventDefault();
      this.updateState();
    });
  }

  updateState() {
    if (this.processing) {
      return;
    }
    this.processing = true;

    let action = this.getCurrentAction();

    $.ajax({
      url: action.url,
      method: action.method,
      dataType: 'json'
    }).done(() => {
      this.processing = false;
      this.raportExists = !this.raportExists;
      this.updateTrigger();
    }).fail(() => {
      this.processing = false;
      alert('We were unable to modify this spam report');
      throw new Error(`Unable to update spam report for ${action.url} ${action.method}`);
    });
  }

  updateTrigger() {
    this.trigger.innerHTML = this.getCurrentAction().label;
  }

  getCurrentAction(): ActionType {
    return this.raportExists ? this.actionCancel : this.actionCreate;
  }
}

module.exports = UserEntryReportSpamAction;
