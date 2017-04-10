// @flow
//
class UserEntryLoader {
  loader: HTMLElement;

  constructor() {
    this.loader = this.build();
  }

  getElement(): HTMLElement {
    return this.loader;
  }

  enable() {
    this.loader.classList.add('is-active');
  }

  toggle() {
    this.loader.classList.toggle('is-active');
  }

  disable() {
    this.loader.classList.remove('is-active');
  }

  build(): HTMLElement {
    let loader = document.createElement('div');
    loader.classList.add('loader', 'loader-default');
    return loader;
  }
}

module.exports = UserEntryLoader;
