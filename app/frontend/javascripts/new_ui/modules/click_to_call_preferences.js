var ClickToCallPreferences = function(el){
    this.wrapper = el;
    this.toggler = el.querySelector('[data-ctc-toggler]');
    this.toggleForm = document.getElementById('edit_click_to_call_preferences');
    this.connectDetails = el.querySelector('.connection-details');

    this.connectForm = el.querySelector('.twilio-connect-form');
    this.connectFormSubmit = el.querySelector('.twilio-connect-form [type="submit"]');
    this.labels = {
        validationCode: _.template(el.dataset.labelValidationCode),
        successMessage: _.template(el.dataset.labelSuccessMessage),
        errorMessage: _.template(el.dataset.labelErrorMessage)
    }

    this.bindEvents();
};

ClickToCallPreferences.prototype.bindEvents = function(){
    this.toggler.addEventListener('change', this.toggleOptions.bind(this));

    var initBound = this.initializeConnect.bind(this);
    if (this.connectForm) {
        this.connectForm.addEventListener('submit', function(e){
            e.preventDefault();
            initBound();
        });
    }
};

ClickToCallPreferences.prototype.initializeConnect = function(){
    this.disableConnectForm();
    this.cleanupConnectionForm();

    $.ajax({
        url: this.connectForm.action,
        method: this.connectForm.method,
        dataType: 'json',
        data: $(this.connectForm).serialize()
    })
    .done(this.processConnectResult.bind(this))
    .fail(this.processConnectError.bind(this));
};

ClickToCallPreferences.prototype.enableConnectForm = function(){
    this.connectFormSubmit.disabled = false;
    this.connectForm.classList.remove('in-progress');
};

ClickToCallPreferences.prototype.disableConnectForm = function(){
    this.connectFormSubmit.disabled = true;
    this.connectForm.classList.add('in-progress');
};

ClickToCallPreferences.prototype.processConnectResult = function(data) {
    if (!data.status || data.status === 'error') {
        this.showConnectionError(data.message);
        return this.enableConnectForm();
    }

    else if (data.status === 'new') {
        this.infobox = document.createElement('div');
        this.infobox.classList.add('validation-code-info');
        this.infobox.innerHTML = this.labels.validationCode({ code: data.message });
        this.wrapper.appendChild(this.infobox);

        this.connectForm.parentNode.removeChild(this.connectForm);

        /* Start polling for response from Twilio */

        this.verifiedPollUrl = data.poll_url;

        this.startPolling();
    }
    else if (data.status === 'verified') {
        this.connectForm.parentNode.removeChild(this.connectForm);
        this.connectionSuccess(data.phone);
    }

    throw new Error('Invalid connection response.');
};

ClickToCallPreferences.prototype.startPolling = function(){
    $.ajax({
        method: 'get',
        url: this.verifiedPollUrl
    }).done(this.pollVerifiedStatus.bind(this));
};

ClickToCallPreferences.prototype.pollVerifiedStatus = function(data){
    if (!data.status) {
        window.setTimeout($.proxy(function(){
            this.startPolling();
        },this), 3000);
        return;
    }

    this.infobox.parentNode.removeChild(this.infobox);

    this.connectionSuccess(data.phone);
};

ClickToCallPreferences.prototype.connectionSuccess = function(phone){

    var successMessage = document.createElement('p');
    successMessage.classList.add('alert','alert-success');
    successMessage.innerHTML = this.labels.successMessage({ phone: phone })

    this.wrapper.appendChild(successMessage);
}

ClickToCallPreferences.prototype.processConnectError = function() {
    this.showConnectionError(this.labels.errorMessage());
    this.enableConnectForm();
};

ClickToCallPreferences.prototype.showConnectionError = function(message){
    var notice = document.createElement('div');
    notice.classList.add('label','label-danger');
    notice.innerHTML = message;
    this.wrapper.appendChild(notice);
};

ClickToCallPreferences.prototype.cleanupConnectionForm = function(message){
    Array.prototype.forEach.call(this.wrapper.querySelectorAll('.label'), function(el){
        el.parentNode.removeChild(el);
    });
};

ClickToCallPreferences.prototype.toggleOptions = function(){
    if (this.toggler.checked) {
        this.connectDetails.classList.add('active');
    }
    else {
        this.connectDetails.classList.remove('active');
    }

    $.ajax({
        url: this.toggleForm.action,
        method: this.toggleForm.method,
        dataType: 'json',
        data: $(this.toggleForm).serialize()
    });
};

module.exports = ClickToCallPreferences;
