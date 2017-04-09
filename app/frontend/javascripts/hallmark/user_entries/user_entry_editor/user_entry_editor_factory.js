// @flow
import type UserEntryEditor from './user_entry_editor';
import UserEntryEditorSimpleMDE from './user_entry_editor_simple_mde';
import UserEntryEditorTextarea from './user_entry_editor_textarea';
import { closest } from '../../../toolkit/dom';

class UserEntryEditorFactory {
  static get(textarea: HTMLTextAreaElement): UserEntryEditor {
    let form = closest(textarea, 'form');
    if (!form) {
      throw new Error('Unable to find form for the User Entry Editor');
    }
    if (form.hasAttribute('data-user-entry-form-rich')) {
      return new UserEntryEditorSimpleMDE(textarea);
    }

    return new UserEntryEditorTextarea(textarea);
  }
}

module.exports = UserEntryEditorFactory;
