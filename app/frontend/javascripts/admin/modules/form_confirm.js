class FormConfirm {
  constructor(form) {
    this.form = form;

    this.message = this.form.dataset.confirm || 'Are you sure you want to continue?';
    this.labelYes = this.form.dataset.confirmLabelYes || 'Yes';
    this.labelNo = this.form.dataset.confirmLabelNo || 'No';

    this.build();
    this.bindEvents();
  }

  build() {
    this.confirmBox = document.createElement('div');
    this.confirmBox.classList.add('confirm-box');
    this.confirmBox.setAttribute('aria-hidden', true);

    this.confirmBox.innerHTML = `<p>
            ${this.message}
            <button type="button" class="btn btn-flat confirm-box-no">${this.labelNo}</button>
            <button type="button" class="btn confirm-box-yes">${this.labelYes}</button>
            </p>`;

    this.form.appendChild(this.confirmBox);

    this.cancelButton = this.form.querySelector('button.confirm-box-no');
    this.confirmButton = this.form.querySelector('button.confirm-box-yes');
  }

  bindEvents() {
    this.form.addEventListener('submit', e => {
      e.preventDefault();
      this.showConfirmBox();
    });

    this.cancelButton.addEventListener('click', e => {
      e.preventDefault();
      this.cancel();
    });

    this.confirmButton.addEventListener('click', e => {
      e.preventDefault();
      this.confirm();
    });
  }

  showConfirmBox() {
    this.focusElement = document.activeElement;
    this.confirmBox.setAttribute('aria-hidden', false);
    this.confirmBox.classList.add('active');
    this.cancelButton.focus();
  }

  cancel() {
    this.confirmBox.setAttribute('aria-hidden', true);
    this.confirmBox.classList.remove('active');
    this.focusElement.focus();
  }

  confirm() {
    this.form.submit();
  }
}

module.exports = FormConfirm;
