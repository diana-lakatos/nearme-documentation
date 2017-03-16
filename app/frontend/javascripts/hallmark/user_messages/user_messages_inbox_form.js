// @flow

const BODY_INPUT_SELECTOR = '[data-user-messages-inbox-body-input]';
const FILE_INPUT_SELECTOR = '[data-user-messages-inbox-file-input]';
const META_SELECTOR = 'meta[name="csrf-token"]';
import Events from 'minivents/dist/minivents.commonjs';
import { findInput, findTextArea, findMeta } from '../../toolkit/dom';
import CommentTextarea from '../comment_textarea/comment_textarea';
import UserMessagesInboxEntry from './user_messages_inbox_entry';
import UserMessagesInboxFileInput from './user_messages_inbox_file_input';

class UserMessagesInboxForm {
  form: HTMLFormElement;
  commentTextarea: CommentTextarea;
  fileInput: UserMessagesInboxFileInput;
  author: string;
  csrfToken: string;
  action: string;

  constructor(form: HTMLFormElement) {
    Events(this);
    this.form = form;

    let textarea = findTextArea(BODY_INPUT_SELECTOR, this.form);
    this.commentTextarea = new CommentTextarea(textarea, { form: this.form });
    this.fileInput = new UserMessagesInboxFileInput(findInput(FILE_INPUT_SELECTOR, this.form), this.form);

    this.author = this.form.dataset.userMessagesInboxCurrentUser;
    if (!this.author) {
      throw new TypeError('Invalid or missing author');
    }

    let action = this.form.getAttribute('action');
    if (!action) {
      throw new TypeError('Attachment form is missing action attribute');
    }
    this.action = action;
    let meta = findMeta(META_SELECTOR);
    this.csrfToken = meta.getAttribute('content');

    this.bindEvents();
  }


  bindEvents() {
    this.fileInput.on('newfile', this.onFileInputChange.bind(this));
    this.form.addEventListener('submit', this.onFormSubmit.bind(this));
  }

  onFileInputChange({ name: name, url: url }: { name: string, url: string } = {}) {
    let entry = new UserMessagesInboxEntry();
    entry.setAuthor(this.author);
    entry.setAttachment(name, url);
    entry.setAuthor(this.author);
    entry.setOwnMessage(true);

    this.emit('newentry', entry);
    this.reset();
  }

  onFormSubmit(event: Event) {
    event.preventDefault();

    this.send();

    let entry = new UserMessagesInboxEntry();
    entry.setAuthor(this.author);
    entry.setOwnMessage(true);

    let body: string = this.commentTextarea.getValue();
    entry.setBody(body);

    this.emit('newentry', entry);
    this.reset();
  }

  send() {
    let request = new XMLHttpRequest();
    request.open('POST', this.action, true);
    request.setRequestHeader('X-CSRF-Token', this.csrfToken);
    request.setRequestHeader('Accept', 'application/json');
    request.responseType = 'json';

    request.onload = () => {
      if (request.status < 200 || request.status >= 400) {
        // rollback ?
        throw new Error('Unable to send attachment');
      }
    };

    request.onerror = () => {
      throw new Error('Unable to reach server to send attachment');
    };

    request.send(new FormData(this.form));
  }

  reset() {
    this.fileInput.empty();
    this.commentTextarea.empty();
  }
}

module.exports = UserMessagesInboxForm;
