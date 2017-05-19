/* global _ */

var ClickToCallPreferences = function(el) {
  this.wrapper = el;
  this.toggler = el.querySelector('[data-ctc-toggler]');
  this.toggleForm = document.getElementById('edit_click_to_call_preferences');
  this.connectDetails = el.querySelector('.connection-details');

  this.connectForm = el.querySelector('.twilio-connect-form');
  this.connectFormSubmit = el.querySelector('.twilio-connect-form [type="submit"]');
  this.disconnectForm = el.querySelector('form[data-disconnect]');
  this.disconnectFormSubmit = el.querySelector('form[data-disconnect] [type="submit"]');
  this.labels = {
    validationCode: _.template(el.dataset.labelValidationCode),
    connectSuccessMessage: _.template(el.dataset.labelConnectSuccessMessage),
    connectErrorMessage: _.template(el.dataset.labelConnectErrorMessage),
    disconnectSuccessMessage: _.template(el.dataset.labelDisconnectSuccessMessage),
    disconnectErrorMessage: _.template(el.dataset.labelDisconnectErrorMessage)
  };

  this.bindEvents();
};

ClickToCallPreferences.prototype.bindEvents = function() {
  var initializeConnectBound, initializeDisconnectBound;

  this.toggler.addEventListener('change', this.toggleOptions.bind(this));

  if (this.connectForm) {
    initializeConnectBound = this.initializeConnect.bind(this);
    this.connectForm.addEventListener('submit', function(e) {
      e.preventDefault();
      initializeConnectBound();
    });
  }

  if (this.disconnectForm) {
    initializeDisconnectBound = this.initializeDisconnect.bind(this);
    this.disconnectForm.addEventListener('submit', function(e) {
      e.preventDefault();
      initializeDisconnectBound();
    });
  }
};

ClickToCallPreferences.prototype.initializeConnect = function() {
  this.disableConnectForm();
  this.cleanupAlerts();

  this
    .xhrFormSubmit(this.connectForm)
    .done(this.processConnectResult.bind(this))
    .fail(this.processConnectError.bind(this));
};

ClickToCallPreferences.prototype.enableConnectForm = function() {
  this.connectFormSubmit.disabled = false;
  this.connectForm.classList.remove('in-progress');
};

ClickToCallPreferences.prototype.disableConnectForm = function() {
  this.connectFormSubmit.disabled = true;
  this.connectForm.classList.add('in-progress');
};

ClickToCallPreferences.prototype.processConnectResult = function(data) {
  if (!data.status || data.status === 'error') {
    this.showError(data.message);
    return this.enableConnectForm();
  } else if (data.status === 'new') {
    this.infobox = document.createElement('div');
    this.infobox.classList.add('validation-code-info');
    this.infobox.innerHTML = this.labels.validationCode({ code: data.message });
    this.wrapper.appendChild(this.infobox);

    this.connectForm.parentNode.removeChild(this.connectForm);

    /* Start polling for response from Twilio */
    this.verifiedPollUrl = data.poll_url;

    this.startPolling();
  } else if (data.status === 'verified') {
    this.connectForm.parentNode.removeChild(this.connectForm);
    this.showSuccess(this.labels.connectSuccessMessage({ phone: data.phone }));
  } else {
    throw new Error('Invalid connection response.');
  }
};

ClickToCallPreferences.prototype.startPolling = function() {
  $.ajax({ method: 'get', url: this.verifiedPollUrl }).done(this.pollVerifiedStatus.bind(this));
};

ClickToCallPreferences.prototype.pollVerifiedStatus = function(data) {
  if (!data.status) {
    window.setTimeout(
      $.proxy(
        function() {
          this.startPolling();
        },
        this
      ),
      3000
    );
    return;
  }

  this.infobox.parentNode.removeChild(this.infobox);

  this.showSuccess(this.labels.connectSuccessMessage({ phone: data.phone }));
};

ClickToCallPreferences.prototype.processConnectError = function() {
  this.showError(this.labels.connectErrorMessage());
  this.enableConnectForm();
};

ClickToCallPreferences.prototype.toggleOptions = function() {
  if (this.toggler.checked) {
    this.connectDetails.classList.add('active');
  } else {
    this.connectDetails.classList.remove('active');
  }

  this.xhrFormSubmit(this.toggleForm);
};

ClickToCallPreferences.prototype.initializeDisconnect = function() {
  this.disconnectFormSubmit.disabled = true;
  this.cleanupAlerts();

  var processDisconnectResult = function() {
    this.showSuccess(this.labels.disconnectSuccessMessage());
    this.disconnectForm.parentNode.remove(this.disconnectForm);
  };

  var processDisconnectError = function() {
    this.showError(this.labels.disconnectErrorMessage());
    this.disconnectFormSubmit.disabled = false;
  };

  this
    .xhrFormSubmit(this.disconnectForm)
    .done(processDisconnectResult.bind(this))
    .fail(processDisconnectError.bind(this));
};

ClickToCallPreferences.prototype.showError = function(message) {
  var el = document.createElement('p');
  el.classList.add('alert', 'alert-danger');
  el.innerHTML = message;
  this.wrapper.appendChild(el);
};

ClickToCallPreferences.prototype.showSuccess = function(message) {
  var el = document.createElement('p');
  el.classList.add('alert', 'alert-success');
  el.innerHTML = message;
  this.wrapper.appendChild(el);
};

ClickToCallPreferences.prototype.cleanupAlerts = function() {
  Array.prototype.forEach.call(this.wrapper.querySelectorAll('.alert'), function(el) {
    el.parentNode.removeChild(el);
  });
};

ClickToCallPreferences.prototype.xhrFormSubmit = function(form, options) {
  var defaults = {
    url: form.action,
    method: form.method,
    dataType: 'json',
    data: $(form).serialize()
  };

  options = options || {};
  options = $.extend({}, defaults, options);
  return $.ajax(options);
};

module.exports = ClickToCallPreferences;
