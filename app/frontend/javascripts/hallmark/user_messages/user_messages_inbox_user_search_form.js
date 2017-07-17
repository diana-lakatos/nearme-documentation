// @flow

const API_URL = '/dashboard/user_messages/search';

import { findInput, findElement } from '../../toolkit/dom';
import Eventable from '../../toolkit/eventable';
const Autocomplete = require('javascript-autocomplete');

class UserMessagesInboxUserSearchForm extends Eventable {
  form: HTMLFormElement;
  input: HTMLInputElement;
  autocomplete: any;

  constructor(form: HTMLFormElement) {
    super();

    this.form = form;
    this.input = findInput('input[type="search"]', form);

    this.initAutocomplete();
    this.bindEvents();
  }

  bindEvents() {
    this.form.addEventListener('submit', (event: Event) => {
      event.preventDefault();
    });
  }

  initAutocomplete() {
    this.autocomplete = new Autocomplete({
      selector: this.input,
      source: this.autocompleteSource.bind(this),
      renderItem: this.renderAutocompleteItem.bind(this),
      onSelect: this.autocompleteOnSelect.bind(this)
    });
  }

  renderAutocompleteItem(item: UserSearchApiResponseItemType, search: string): string {
    search = search.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&');
    let re = new RegExp('(' + search.split(' ').join('|') + ')', 'gi');

    return `<div class="autocomplete-suggestion" data-val="${item.name}" data-id="${item.id}" data-profile-url="${item.profile_url}">
      <img src="${item.avatar_url}" alt="${item.name}">
      ${item.name.replace(re, '<b>$1</b>')}
    </div>`;
  }

  autocompleteSource(term: string, response: (data: UserSearchApiResponseType) => void) {
    $.ajax({
      url: API_URL,
      data: { term: term },
      dataType: 'json'
    }).then((data: { user_messages: UserSearchApiResponseType }) => {
      response(data.user_messages);
    });
  }

  autocompleteOnSelect(event: Event, term: string, item: HTMLElement) {
    let user = this.getUserObjectFromDOM(item);
    this.emit('user:selected', { user: user });
  }

  getUserObjectFromDOM(
    item: HTMLElement
  ): { id: number, name: string, profileUrl: string, avatarUrl: string } {
    let id = parseInt(item.dataset.id, 10);
    if (isNaN(id)) {
      throw new Error(`Invalid or missing user id: ${id}`);
    }

    return {
      id: id,
      name: item.dataset.val,
      profileUrl: item.dataset.profileUrl,
      avatarUrl: findElement('img', item).getAttribute('src')
    };
  }
}

module.exports = UserMessagesInboxUserSearchForm;
