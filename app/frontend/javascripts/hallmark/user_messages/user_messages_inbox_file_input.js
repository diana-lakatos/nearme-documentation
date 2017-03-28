// @flow

type UserMessageResponseType = {
  author: string,
  time: string,
  body: string,
  attachments: Array<{ url: string, fileName: string }>
};

import Events from 'minivents/dist/minivents.commonjs';
import { closest, findMeta } from '../../toolkit/dom';

const PROCESSING_CLASS = 'processing';
const WRAPPER_SELECTOR = '.form-group';
const META_SELECTOR = 'meta[name="csrf-token"]';

class UserMessagesInboxFileInput {
  form: HTMLFormElement;
  input: HTMLInputElement;
  wrapper: HTMLElement;
  csrfToken: string;
  action: string;

  constructor(input: HTMLInputElement, form: HTMLFormElement) {
    Events(this);

    this.input = input;
    this.form = form;

    let action = this.form.getAttribute('action');
    if (!action) {
      throw new TypeError('Attachment form is missing action attribute');
    }
    this.action = action;
    let meta = findMeta(META_SELECTOR);
    this.csrfToken = meta.getAttribute('content');


    let wrapper = closest(this.input, WRAPPER_SELECTOR);
    if (!(wrapper instanceof HTMLElement)) {
      throw new Error('Unable to locate file input wrapper');
    }
    this.wrapper = wrapper;


    this.bindEvents();
  }


  bindEvents() {
    this.input.addEventListener('change', this.onChange.bind(this));
  }

  onChange() {
    this.wrapper.classList.add(PROCESSING_CLASS);

    this.send()
        .then((response: UserMessageResponseType) => {
          response.attachments.forEach((attachment) => {
            this.emit('newfile', attachment);
          });
          this.wrapper.classList.remove(PROCESSING_CLASS);
        })
        .catch((error) => {
          this.wrapper.classList.remove(PROCESSING_CLASS);
          alert(error);
        });
  }

  send(): Promise<any> {
    return new Promise((resolve, reject) => {
      let request = new XMLHttpRequest();
      request.open('POST', this.action, true);
      request.setRequestHeader('X-CSRF-Token', this.csrfToken);
      request.setRequestHeader('Accept', 'application/json');
      request.responseType = 'json';

      request.onload = () => {
        if (request.status < 200 || request.status >= 400) {
          reject('Unable to send attachment');
          return;
        }
        resolve(request.response);
      };

      request.onerror = () => {
        reject('Unable to reach server to send attachment');
      };

      request.send(new FormData(this.form));
    });
  }

  empty() {
    this.input.value = '';
  }
}

module.exports = UserMessagesInboxFileInput;
