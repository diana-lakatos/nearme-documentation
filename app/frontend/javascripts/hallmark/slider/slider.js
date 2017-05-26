/* @flow */
import type Thumbnail from './thumbnails/thumbnail';
import ThumbnailFactory from './thumbnails/thumbnail_factory';
import { findElement, findButton } from '../../toolkit/dom';
import { requestNextAnimationFrame } from '../../toolkit/animation';
import { throttle } from 'lodash';

const DISABLED_CLASS = 'disabled';

class Slider {
  container: HTMLElement;
  wrapper: HTMLElement;
  list: HTMLElement;
  itemsPerPage: number;
  nav: HTMLElement;
  previousButton: HTMLButtonElement;
  nextButton: HTMLButtonElement;
  totalItems: number;
  currentPosition: number;
  initialTransition: string;
  thumbnails: Array<Thumbnail>;

  constructor(container: HTMLElement) {
    this.container = container;
    this.wrapper = findElement('[data-slider-wrap]', container);
    this.list = findElement('[data-slider-list]', this.wrapper);

    this.initialTransition = window.getComputedStyle(this.list).transition;

    this.totalItems = this.getTotalItemsCount();
    this.itemsPerPage = this.determineItemsCountPerPage();
    this.currentPosition = 0;

    this.nav = this.buildNavigation();
    this.previousButton = findButton('[data-slider-previous]', this.nav);
    this.nextButton = findButton('[data-slider-next]', this.nav);
    this.container.insertAdjacentElement('beforeend', this.nav);

    this.thumbnails = this.initThumbnails();

    this.setPosition(this.currentPosition);
    this.bindEvents();
  }

  initThumbnails(): Array<Thumbnail> {
    let links = this.list.querySelectorAll('a');
    links = Array.prototype.map.call(links, (link: HTMLLinkElement): Thumbnail => {
      return ThumbnailFactory.get(link);
    });

    return links;
  }

  getTotalItemsCount(): number {
    return this.wrapper.querySelectorAll('li').length;
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
    let li = this.wrapper.querySelector('li');
    if (!(li instanceof HTMLElement)) {
      throw new Error('Unable to fetch first element in slider');
    }
    return Math.round(this.wrapper.offsetWidth / li.offsetWidth);
  }

  determineTotalPagesCount(): number {
    return Math.ceil(this.totalItems / this.itemsPerPage);
  }

  setPosition(position: number, instant: ?boolean = false) {
    if (position < 0 || position >= this.totalItems) {
      return;
    }

    position = this.accountForMaxPosition(position, this.itemsPerPage, this.totalItems);

    this.currentPosition = position;

    this.thumbnails
      .slice(position, position + this.itemsPerPage)
      .forEach((thumbnail: Thumbnail) => {
        thumbnail.load();
      });

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
