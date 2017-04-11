// @flow
import UserEntryEditor from './user_entry_editor';
import SimpleMDE from 'simplemde';
import { closest } from '../../../toolkit/dom';

const WRAPPER_SELECTOR = '[data-user-entry-form-wrapper]';
const FOCUSED_CLASS = 'focused';

class UserEntryEditorSimpleMDE extends UserEntryEditor {
  editor: SimpleMDE;
  cm: any;
  overlay: HTMLElement;
  wrapper: HTMLElement;
  isActive: boolean;
  body: HTMLElement;

  constructor(textarea: HTMLTextAreaElement) {
    super(textarea);

    this.isActive = false;

    let wrapper = closest(textarea, WRAPPER_SELECTOR);
    if (!wrapper) {
      throw new Error('Unable to locate wrapper for UserEntryEditorSimpleMDE');
    }
    this.wrapper = wrapper;
    this.wrapper.setAttribute('tabindex', this.wrapper.getAttribute('tabindex') || 0);

    let body = document.querySelector('body');
    if (!body) {
      throw new Error('Invalid context');
    }
    this.body = body;

    this.editor = this.initialize();
    this.cm = this.editor.codemirror;

    this.bindEvents();
  }

  initialize(): SimpleMDE {
    let overlay = document.createElement('div');
    overlay.classList.add('user-entry-form-overlay');
    this.wrapper.insertAdjacentElement('afterbegin', overlay);
    this.overlay = overlay;


    const options = {
      element: this.textarea,
      autoDownloadFontAwesome: false,
      placeholder: this.textarea.getAttribute('placeholder') || null,
      hideIcons: ['image', 'heading', 'side-by-side', 'fullscreen']
    };

    return new SimpleMDE(options);
  }

  bindEvents() {
    this.cm.on('focus', this.activate.bind(this));

    this.textarea.addEventListener('focus', () => {
      this.cm.focus();
      this.cm.setCursor(this.cm.lineCount(), 0);
    });

    this.overlay.addEventListener('click', this.deactivate.bind(this));
    this.body.addEventListener('keydown', this.keyDownHandler.bind(this));
  }

  keyDownHandler(event: Event) {
    // on escape
    if (event.keyCode !== 27 || this.isActive === false) {
      return;
    }

    this.deactivate();
  }

  activate() {
    this.wrapper.classList.add(FOCUSED_CLASS);
    this.isActive = true;
    this.cm.refresh();
  }

  deactivate() {
    this.isActive = false;
    this.wrapper.classList.remove(FOCUSED_CLASS);
    this.wrapper.focus();
  }

  getValue(): string {
    return this.editor.value();
  }

  setValue(value: string) {
    this.editor.value(value);
    this.sync();
  }

  focus() {
    this.cm.focus();
  }

  empty() {
    this.editor.value('');
    this.sync();
  }

  rollback() {
    this.editor.value(this.initialValue);
    this.sync();
  }

  sync() {
    this.cm.save();
  }
}

module.exports = UserEntryEditorSimpleMDE;
