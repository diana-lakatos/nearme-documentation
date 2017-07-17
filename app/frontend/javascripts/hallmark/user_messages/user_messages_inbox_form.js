// @flow

const BODY_INPUT_SELECTOR = '[data-user-messages-inbox-body-input]';
const FILE_INPUT_SELECTOR = '[data-user-messages-inbox-file-input]';
const META_SELECTOR = 'meta[name="csrf-token"]';
import Eventable from '../../toolkit/eventable';
import { findInput, findTextArea, findMeta, closest } from '../../toolkit/dom';
import CommentTextarea from '../comment_textarea/comment_textarea';
import LimitedInput from '../../components/limited_input';
import UserMessagesInboxEntry from './user_messages_inbox_entry';

const FILE_PROCESSING_CLASS = 'processing';
const FILE_WRAPPER_SELECTOR = '.attachment';

class UserMessagesInboxForm extends Eventable {
  form: HTMLFormElement;
  commentTextarea: CommentTextarea;
  fileInput: HTMLInputElement;
  fileWrapper: HTMLElement;
  author: string;
  csrfToken: string;
  action: string;
  processing: boolean;

  constructor(form: HTMLFormElement) {
    super();

    this.form = form;
    this.processing = false;

    let textarea = findTextArea(BODY_INPUT_SELECTOR, this.form);

    new LimitedInput(textarea);

    this.commentTextarea = new CommentTextarea(textarea, { form: this.form });
    this.fileInput = findInput(FILE_INPUT_SELECTOR, this.form);
    let fileWrapper = closest(this.fileInput, FILE_WRAPPER_SELECTOR);
    if (!(fileWrapper instanceof HTMLElement)) {
      throw new Error('Unable to locate file input wrapper');
    }
    this.fileWrapper = fileWrapper;

    this.author = this.form.dataset.userMessagesInboxCurrentUser;
    if (!this.author) {
      throw new TypeError('Invalid or missing author');
    }

    let action = this.form.getAttribute('action');
    if (!action) {
      throw new Error('Missing action attribute on form');
    }
    this.action = action;
    this.csrfToken = findMeta(META_SELECTOR).getAttribute('content');

    this.bindEvents();
  }

  bindEvents() {
    this.fileInput.addEventListener('change', this.handleFileInputChange.bind(this));
    this.form.addEventListener('submit', this.handleFormSubmit.bind(this));
  }

  handleFileInputChange() {
    this.fileWrapper.classList.add(FILE_PROCESSING_CLASS);

    if (this.processing) {
      return;
    }
    this.processing = true;
    this.send()
      .then(this.processResponse.bind(this))
      .then((entry: UserMessagesInboxEntry) => {
        this.emit('newentry', entry);
        this.fileWrapper.classList.remove(FILE_PROCESSING_CLASS);
        this.processing = false;
        this.reset();
      })
      .catch(error => {
        this.fileWrapper.classList.remove(FILE_PROCESSING_CLASS);
        this.processing = false;
        alert(error);
      });
  }

  handleFormSubmit(event: Event) {
    event.preventDefault();

    if (this.processing) {
      return;
    }
    this.processing = true;

    this.send().then(this.processResponse.bind(this)).then((entry: UserMessagesInboxEntry) => {
      this.emit('newentry', entry);
      this.processing = false;
      this.reset();
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
          reject('Unable to send the message');
          return;
        }
        resolve(request.response);
      };

      request.onerror = () => {
        reject('Unable to reach server to send the message');
      };

      request.send(new FormData(this.form));
    });
  }

  processResponse(userMessageResponse: UserMessageResponseType): Promise<UserMessagesInboxEntry> {
    return new Promise(resolve => {
      let entry = new UserMessagesInboxEntry();

      entry.setId(userMessageResponse.id);
      entry.setAuthor(userMessageResponse.author);
      entry.setOwnMessage(true);

      userMessageResponse.attachments.forEach(({ name, url }: { name: string, url: string }) => {
        entry.addAttachment(name, url);
      });

      if (userMessageResponse.body.trim() !== '') {
        entry.setBody(userMessageResponse.body);
      }

      resolve(entry);
    });
  }

  reset() {
    this.fileInput.value = '';
    this.commentTextarea.empty();
  }
}

module.exports = UserMessagesInboxForm;
