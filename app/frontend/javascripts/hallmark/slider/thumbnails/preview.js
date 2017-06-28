// @flow
import { findElement, findButton, closest } from '../../../toolkit/dom';

const ACTIVE_CLASS = 'slider-lightbox-active';
const SLIDER_CLASS = 'slider-lightbox';
const SLIDER_CONTENT_CLASS = 'slider-lightbox-content';
const CLOSE_BUTTON_CLASS = 'slider-lightbox-close';
const REMOVE_TIMEOUT = 550;

class Preview {
  container: HTMLElement;
  content: HTMLElement;
  closeButton: HTMLButtonElement;
  onKeyDown: Function;

  constructor() {
    this.onKeyDown = this.onKeyDown.bind(this);
    this.build();
    this.bindEvents();
  }

  build() {
    let container = document.createElement('div');
    container.classList.add(SLIDER_CLASS);

    container.innerHTML = `
      <div class="slider-lightbox-content"></div>
      <button type="button" class="slider-lightbox-close">Close</button>`;

    this.container = container;
    this.content = findElement(`.${SLIDER_CONTENT_CLASS}`, container);
    this.closeButton = findButton(`.${CLOSE_BUTTON_CLASS}`, container);
  }

  bindEvents() {
    this.closeButton.addEventListener('click', (e: Event) => {
      e.preventDefault();
      this.close();
    });

    this.container.addEventListener('click', (e: Event) => {
      if (e.defaultPrevented) {
        return;
      }
      if (!closest(e.target, `.${SLIDER_CONTENT_CLASS}`)) {
        e.preventDefault();
        this.close();
      }
    });
  }

  open() {
    let body = findElement('body');
    this.container.classList.add(ACTIVE_CLASS);
    body.appendChild(this.container);
    body.addEventListener('keydown', this.onKeyDown);
  }

  onKeyDown(e: KeyboardEvent) {
    if (e.keyCode !== 27) {
      return;
    }

    e.preventDefault();
    this.close();
  }

  close() {
    this.container.classList.remove(ACTIVE_CLASS);
    let body = findElement('body');
    body.removeEventListener('keydown', this.onKeyDown);
    window.setTimeout(() => {
      this.container = body.removeChild(this.container);
    }, REMOVE_TIMEOUT);
  }

  setContent(html: string) {
    this.content.innerHTML = html;
  }

  getContainer(): HTMLElement {
    if (!(this.container instanceof HTMLElement)) {
      throw new Error('Unable to fetch container, build the preview first');
    }
    return this.container;
  }
}

export default Preview;
