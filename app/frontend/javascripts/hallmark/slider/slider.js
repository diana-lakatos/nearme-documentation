/* @flow */
import { findElement, findButton } from '../../toolkit/dom';
import { requestNextAnimationFrame } from '../../toolkit/animation';
const throttle = require('lodash/throttle');

const DISABLED_CLASS = 'disabled';
const WRAPPER_SELECTOR = '[data-slider-wrap]';
const LIST_SELECTOR = '[data-slider-list]';

class Slider {
  container: HTMLElement;
  wrapper: HTMLElement;
  list: HTMLElement;
  itemsPerPage: number;
  nav: HTMLElement;
  previousButton: HTMLButtonElement;
  nextButton: HTMLButtonElement;
  totalItems: number;
  currentPosition: number; // index of the first item on the page
  initialTransition: string;
  itemProvider: SliderItemProvider;

  constructor(container: HTMLElement, itemProvider: SliderItemProvider) {
    this.container = container;
    this.wrapper = findElement(WRAPPER_SELECTOR, container);
    this.list = findElement(LIST_SELECTOR, this.wrapper);

    this.initialTransition = window.getComputedStyle(this.list).transition;

    this.itemProvider = itemProvider;

    this.itemsPerPage = this.determineItemsCountPerPage();
    this.currentPosition = 0;

    this.itemProvider.getTotalItemsCount().then((totalItems: number) => {
      this.totalItems = totalItems;
      this.nav = this.buildNavigation();
      this.previousButton = findButton('[data-slider-previous]', this.nav);
      this.nextButton = findButton('[data-slider-next]', this.nav);
      this.container.insertAdjacentElement('beforeend', this.nav);
      this.setPosition(this.currentPosition, true);
      this.bindEvents();
    });
  }

  buildNavigation(): HTMLElement {
    let nav = document.createElement('ul');
    nav.classList.add('slider-a-nav');

    nav.innerHTML = `
      <li class="prev"><button type="button" data-slider-previous>Previous</button></li>
      <li class="next"><button type="button" data-slider-next>Next</button></li>
    `;

    return nav;
  }

  bindEvents() {
    this.previousButton.addEventListener('click', (e: Event) => {
      e.preventDefault();
      this.previousPage();
    });

    this.nextButton.addEventListener('click', (e: Event) => {
      e.preventDefault();
      this.nextPage();
    });

    let onResize = throttle(() => {
      this.reinitializeNavigation();
    }, 100);

    window.addEventListener('resize', onResize);
  }

  nextPage() {
    let position = this.currentPosition + this.itemsPerPage;
    if (position >= this.totalItems) {
      position = this.totalItems - 1;
    }

    this.setPosition(position);
  }

  previousPage() {
    let position = this.currentPosition - this.itemsPerPage;
    if (position < 0) {
      position = 0;
    }

    this.setPosition(position);
  }

  toggleNextButton(state: boolean) {
    if (state) {
      this.nextButton.removeAttribute('disabled');
      this.nextButton.classList.remove(DISABLED_CLASS);
      return;
    }
    this.nextButton.setAttribute('disabled', 'disabled');
    this.nextButton.classList.add(DISABLED_CLASS);
  }

  togglePreviousButton(state: boolean) {
    if (state) {
      this.previousButton.removeAttribute('disabled');
      this.previousButton.classList.remove(DISABLED_CLASS);
      return;
    }
    this.previousButton.setAttribute('disabled', 'disabled');
    this.previousButton.classList.add(DISABLED_CLASS);
  }

  determineItemsCountPerPage(): number {
    let li = this.list.firstElementChild;
    if (!(li instanceof HTMLElement)) {
      throw new Error('Unable to fetch first element in slider');
    }
    return Math.round(this.wrapper.offsetWidth / li.offsetWidth);
  }

  setPosition(position: number, instant: ?boolean = false) {
    if (position < 0 || position >= this.totalItems) {
      return;
    }

    position = this.accountForMaxPosition(position, this.itemsPerPage, this.totalItems);

    this.currentPosition = position;

    this.itemProvider.load(position, position + this.itemsPerPage);

    this.slideTo(position, instant);

    this.togglePreviousButton(position > 0);
    this.toggleNextButton(position < this.totalItems - this.itemsPerPage);
  }

  slideTo(position: number, instant: ?boolean = false) {
    let transform = `translateX(-${position / this.itemsPerPage * 100}%)`;

    this.list.style.transform = transform;
    this.list.style.webkitTransform = transform;

    if (instant) {
      this.list.style.transition = 'none';
    }
    this.list.style.transform = transform;
    this.list.style.webkitTransform = transform;

    if (instant) {
      requestNextAnimationFrame(() => {
        this.list.style.transition = this.initialTransition;
      });
    }
  }

  accountForMaxPosition(position: number, itemsPerPage: number, totalItems: number): number {
    return Math.min(totalItems - itemsPerPage, position);
  }

  reinitializeNavigation() {
    let itemsPerPage = this.determineItemsCountPerPage();
    if (itemsPerPage === this.itemsPerPage) {
      return;
    }

    this.itemsPerPage = itemsPerPage;
    this.setPosition(this.currentPosition, true);
  }
}

module.exports = Slider;
