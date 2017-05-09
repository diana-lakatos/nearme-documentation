// @flow
const CSRF_META_SELECTOR = 'meta[name="csrf-token"]';
const FOLLOW_CLASS = 'action--follow';
const UNFOLLOW_CLASS = 'action--unfollow';

import { findInput, findButton } from '../../toolkit/dom';

class FollowButtonForm {
  form: HTMLFormElement;
  state: boolean;
  previousState: boolean;
  followUrl: string;
  unfollowUrl: string;
  followLabel: string;
  unfollowLabel: string;
  csrfToken: string;
  methodInput: HTMLInputElement;
  button: HTMLButtonElement;
  followersCounters: NodeList<HTMLElement>;

  constructor(form: HTMLFormElement) {
    this.form = form;

    this.followUrl = this.form.dataset.followUrl;
    this.unfollowUrl = this.form.dataset.unfollowUrl;
    this.followLabel = this.form.dataset.followLabel || 'Follow';
    this.unfollowLabel = this.form.dataset.unfollowLabel || 'Unfollow';
    this.state = this.form.dataset.followState === 'true';

    if (!this.followUrl) {
      throw new Error('Missing follow url attribute in follow button form');
    }

    if (!this.unfollowUrl) {
      throw new Error('Missing unfollow url attribute in follow button form');
    }

    this.methodInput = findInput('[data-method]', this.form);
    this.button = findButton('button', this.form);

    this.followersCounters = document.querySelectorAll(
      `[data-followers-count="${this.form.dataset.followersCounterId}"]`
    );

    this.setCSRFToken();
  }

  setCSRFToken() {
    let meta = document.querySelector(CSRF_META_SELECTOR);
    if (!(meta instanceof HTMLMetaElement)) {
      throw new Error('Unable to find locate ');
    }
    this.csrfToken = meta.content;
  }

  process() {
    this.previousState = this.state;
    this.submit();

    this.updateFollowersCountBy(this.state ? -1 : 1);
    this.setState(!this.state);
  }

  submit() {
    let data = new FormData(this.form);

    let request = new XMLHttpRequest();
    request.open('POST', this.form.action, true);
    request.setRequestHeader('X-CSRF-Token', this.csrfToken);
    request.setRequestHeader('Accept', 'application/json');
    request.responseType = 'json';

    request.onload = () => {
      if (request.status < 200 || request.status >= 400) {
        this.rollback();
        throw new Error('Unable to change following state');
      }

      this.processResponse(request.response);
    };

    request.onerror = () => {
      this.rollback();
      throw new Error('Unable to reach server to change following state');
    };

    request.send(data);
  }

  setState(state: boolean) {
    if (this.state === state) {
      return;
    }

    let action = state ? this.unfollowUrl : this.followUrl;
    let method = state ? 'DELETE' : 'POST';
    let removeClass = state ? FOLLOW_CLASS : UNFOLLOW_CLASS;
    let addClass = state ? UNFOLLOW_CLASS : FOLLOW_CLASS;
    let label = state ? this.unfollowLabel : this.followLabel;

    this.form.setAttribute('action', action);
    this.methodInput.value = method;
    this.button.classList.remove(removeClass);
    this.button.classList.add(addClass);
    this.button.innerHTML = label;

    this.state = state;
  }

  rollback() {
    this.setState(this.previousState);
  }

  processResponse(
    response: { is_following: boolean, followers_count: number }
  ) {
    $.rails.enableElement($(this.button));
    $(this.button).prop('disabled', false);

    this.setState(response.is_following);
    this.setFollowersCount(response.followers_count);
  }

  setFollowersCount(count: number) {
    Array.prototype.forEach.call(
      this.followersCounters,
      (counter: HTMLElement) => {
        counter.innerHTML = count + '';
      }
    );
  }

  updateFollowersCountBy(delta: number) {
    Array.prototype.forEach.call(
      this.followersCounters,
      (counter: HTMLElement) => {
        let current: number = parseInt(counter.innerHTML, 10) || 0;
        counter.innerHTML = current + delta + '';
      }
    );
  }
}

module.exports = FollowButtonForm;
