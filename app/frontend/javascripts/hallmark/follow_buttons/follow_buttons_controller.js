// @flow
const SELECTOR_ATTRIBUTE = 'data-follow-button-form';
import FollowButtonForm from './follow_button_form';

class FollowButtonsController {
  constructor() {
    this.bindEvents();
  }

  bindEvents() {
    if (document.body) {
      document.body.addEventListener('submit', (event: Event) => {
        let form: FollowButtonHTMLFormElement = (event.target: any);
        if (!(form instanceof HTMLFormElement) || form.hasAttribute(SELECTOR_ATTRIBUTE) === false) {
          return;
        }

        event.preventDefault();

        if (!(form.followButtonForm instanceof FollowButtonForm)) {
          form.followButtonForm = new FollowButtonForm(form);
        }
        form.followButtonForm.process();
      }, true);
    }
  }
}

module.exports = FollowButtonsController;
