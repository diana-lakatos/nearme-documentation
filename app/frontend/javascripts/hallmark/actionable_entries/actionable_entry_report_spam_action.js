let resolver = require('./spam_report_resolver');

class ActionableEntryReportSpamAction {
  constructor(trigger, container) {
    this.trigger = trigger;
    this.raportExists = false;
    this.type = container.dataset.commentId ? 'comment' : 'event';
    this.entryId = container.dataset.commentId ? container.dataset.commentId : container.dataset.activityFeedEventId;
    this.entryId = parseInt(this.entryId, 10);

    this.actionCancel = {
      url: trigger.dataset.cancelReportUrl,
      label: trigger.dataset.cancelReportLabel,
      method: 'delete'
    };

    this.actionCreate = {
      url: trigger.getAttribute('href'),
      label: trigger.innerHTML,
      method: 'post'
    };

    console.log(this.actionCancel);
    console.log(this.actionCreate);

    this.container = container;

    resolver.get().then((data) => {
      this.data = data;
      this.initialize();
    });

    this.bindEvents();
  }

  initialize() {
    let spamReports = this.data[`${this.type}s_spam_reports`];
    console.log(spamReports, this.entryId);

    if (spamReports.indexOf(this.entryId) > -1) {
      this.raportExists = true;
      this.updateTrigger();
    }
  }

  bindEvents() {
    this.trigger.addEventListener('click', (e)=>{
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
    }).done(()=>{
      this.processing = false;
      this.raportExists = !this.raportExists;
      this.updateTrigger();
    }).fail(()=>{
      this.processing = false;
      alert('We were unable to modify this spam report');
      throw new Error(`Unable to update spam report for ${action.url} ${action.method}`);
    });
  }

  updateTrigger() {
    this.trigger.innerHTML = this.getCurrentAction().label;
  }

  getCurrentAction() {
    return this.raportExists ? this.actionCancel : this.actionCreate;
  }
}

module.exports = ActionableEntryReportSpamAction;
