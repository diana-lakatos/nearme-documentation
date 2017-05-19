// @flow
class UserEntryEditor {
  textarea: HTMLTextAreaElement;
  initialValue: string;

  constructor(textarea: HTMLTextAreaElement) {
    this.textarea = textarea;
    this.initialValue = textarea.value;
  }

  getValue(): string {
    return this.textarea.value;
  }

  setValue(value: string) {
    this.textarea.value = value;
  }

  sync() {}

  rollback() {
    this.textarea.value = this.initialValue;
  }

  focus() {
    let val = this.textarea.value;
    this.textarea.focus();
    this.textarea.value = '';
    this.textarea.value = val;
  }

  empty() {
    this.textarea.value = '';
  }
}

module.exports = UserEntryEditor;
