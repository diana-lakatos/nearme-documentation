// @flow

import { findElement } from '../../../toolkit/dom';

const LIST_SELECTOR = '[data-slider-list]';
const DAYS_TO_SHOW = 60;

class EndpointSliderItemProvider implements SliderItemProvider {
  container: HTMLElement;
  slides: Array<SliderItemType>;
  slidesCountPromise: Promise<number>;
  list: HTMLElement;
  loader: EndpointLoader;

  constructor(container: HTMLElement, loader: EndpointLoader) {
    this.container = container;
    this.loader = loader;
    this.container = container;
    this.list = findElement(LIST_SELECTOR, this.container);
    this.slides = [];

    this.slidesCountPromise = this.createTotalSlidesCountPromise();
    this.preloadExistingSlides();
  }

  preloadExistingSlides() {
    Array.prototype.forEach.call(this.list.children, (element: HTMLElement, index: number) => {
      this.slides[index] = { loaded: true, element: element };
      if (typeof this.loader.afterLoadedCallback === 'function') {
        this.loader.afterLoadedCallback(element);
      }
    });
  }

  getPaginationSettings(
    startIndex: number = 0,
    endIndex: number = 0
  ): { page: number, perPage: number } {
    let objectsPerSlide = this.loader.getObjectsCountInOneSlide();

    let slidesPerPage = endIndex + 1 - startIndex || this.loader.getMinimumSlidesPerPageCount();

    let perPaginationPage = slidesPerPage * objectsPerSlide;
    let page = Math.ceil((startIndex * objectsPerSlide + 1) / perPaginationPage);

    return { page: page, perPage: perPaginationPage };
  }

  load(startIndex: number, endIndex: number): Promise<any> {
    endIndex = endIndex || startIndex;

    if (endIndex > this.slides.length - 1) {
      endIndex = this.slides.length - 1;
    }

    let slides = this.slides.slice(startIndex, endIndex + 1);

    return new Promise(resolve => {
      if (slides.every((slide): boolean => slide.loaded)) {
        resolve();
        return;
      }

      this.buildPlaceholderElements(startIndex, endIndex);

      let { page, perPage } = this.getPaginationSettings(startIndex, endIndex);

      fetch(this.loader.getEndpointUrl(page, perPage))
        .then((response: Response): Promise<CommentEndpointResponseType> => {
          return response.json();
        })
        .then(this.loader.parseEndpointData)
        .then((dataItems: Array<any>) => {
          dataItems.forEach((data: any, index) => {
            let slide = this.slides[startIndex + index];
            let element = slide.element;

            if (!slide || !(element instanceof HTMLElement)) {
              throw new Error('Element has not be instantiated correctly');
            }

            if (slide.loaded) {
              return;
            }
            this.loader.populatePlaceholderElement(slide, data);
            if (typeof this.loader.afterLoadedCallback === 'function') {
              this.loader.afterLoadedCallback(element);
            }
          });
          resolve();
        })
        .catch((err: string) => {
          throw new Error(`Unable to fetch projects data from endpoint ${err}`);
        });
    });
  }

  getSinceParam(): number {
    let now = new Date();
    return Math.round((now.getTime() - 1000 * 60 * 60 * 24 * DAYS_TO_SHOW) / 1000);
  }

  createTotalSlidesCountPromise(): Promise<number> {
    let { page, perPage } = this.getPaginationSettings(0, 1);

    return new Promise(resolve => {
      fetch(this.loader.getEndpointUrl(page, perPage, this.getSinceParam()))
        .then((response: Response): Promise<any> => {
          return response.json();
        })
        .then(this.loader.parseTotalSlidesCountResponse)
        .then((totalCount: number) => {
          this.createPlaceholders(totalCount);
          resolve(totalCount);
        });
    });
  }

  getTotalSlidesCount(): Promise<number> {
    return this.slidesCountPromise;
  }

  createPlaceholders(totalCount: number) {
    for (let i = 0; i < totalCount; i++) {
      /* do not overwrite exisitng items */
      if (this.slides[i]) {
        continue;
      }
      this.slides[i] = { loaded: false, element: null };
    }
  }

  buildPlaceholderElements(startIndex: number, endIndex: number) {
    for (let i = startIndex; i <= endIndex; i++) {
      // omit existing elemenets
      if (this.slides[i].element) {
        continue;
      }
      let li = this.loader.buildPlaceholderElement();
      this.list.appendChild(li);
      this.slides[i].element = li;
    }
  }
}

export default EndpointSliderItemProvider;
