// @flow

import { findElement } from '../../../toolkit/dom';

const LIST_SELECTOR = '[data-slider-list]';
const DAYS_TO_SHOW = 356;

class EndpointSliderItemProvider implements SliderItemProvider {
  container: HTMLElement;
  container: HTMLElement;
  items: Array<SliderItemType>;
  itemsCountPromise: Promise<number>;
  list: HTMLElement;
  loader: EndpointLoader;

  constructor(container: HTMLElement, loader: EndpointLoader) {
    this.container = container;
    this.loader = loader;
    this.container = container;
    this.list = findElement(LIST_SELECTOR, this.container);
    this.items = [];

    this.itemsCountPromise = this.createTotalItemsCountPromise();
    this.preloadExistingItems();
  }

  preloadExistingItems() {
    Array.prototype.forEach.call(this.list.children, (element: HTMLElement, index: number) => {
      this.items[index] = { loaded: true, element: element };
      if (typeof this.loader.afterLoadedCallback === 'function') {
        this.loader.afterLoadedCallback(element);
      }
    });
  }

  getPaginationSettings(
    startIndex: number = 0,
    endIndex: number = 1
  ): { since: number, page: number, perPage: number } {
    let now = new Date();
    let since = Math.round((now.getTime() - 60 * 60 * 24 * DAYS_TO_SHOW * 1000) / 1000);

    startIndex = startIndex * this.loader.getObjectsCountInOneSlide();
    endIndex = endIndex * this.loader.getObjectsCountInOneSlide();

    let perPage = endIndex ? endIndex - startIndex : this.loader.getDefaultItemsPerPageCount();
    let page = Math.ceil((startIndex + 1) / perPage);

    return { since: since, page: page, perPage: perPage };
  }

  load(startIndex: number, endIndex: number): Promise<any> {
    endIndex = endIndex || startIndex + 1;

    let items = this.items.slice(startIndex, endIndex);

    return new Promise(resolve => {
      if (items.every((item): boolean => item.loaded)) {
        resolve();
        return;
      }

      this.buildPlaceholderElements(startIndex, endIndex);

      let { since, page, perPage } = this.getPaginationSettings(startIndex, endIndex);

      fetch(this.loader.getEndpointUrl(since, page, perPage))
        .then((response: Response): Promise<CommentEndpointResponseType> => {
          return response.json();
        })
        .then(this.loader.parseEndpointData)
        .then((dataItems: Array<any>) => {
          dataItems.forEach((data: any, index) => {
            let item = this.items[startIndex + index];
            let element = item.element;

            if (!item || !(element instanceof HTMLElement)) {
              throw new Error('Element has not be instantiated correctly');
            }

            if (item.loaded) {
              return;
            }
            this.loader.populatePlaceholderElement(item, data);
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

  createTotalItemsCountPromise(): Promise<number> {
    let { since, page, perPage } = this.getPaginationSettings(0, 1);

    return new Promise(resolve => {
      fetch(this.loader.getEndpointUrl(since, page, perPage))
        .then((response: Response): Promise<any> => {
          return response.json();
        })
        .then(this.loader.parseTotalEntriesResponse)
        .then((totalCount: number) => {
          this.createPlaceholders(totalCount);
          resolve(totalCount);
        });
    });
  }

  getTotalItemsCount(): Promise<number> {
    return this.itemsCountPromise;
  }

  createPlaceholders(totalCount: number) {
    for (let i = 0; i < totalCount; i++) {
      /* do not overwrite exisitng items */
      if (this.items[i]) {
        continue;
      }
      this.items[i] = { loaded: false, element: null };
    }
  }

  buildPlaceholderElements(startIndex: number, endIndex: number) {
    for (let i = startIndex; i <= endIndex; i++) {
      // omit existing elemenets
      if (this.items[i].element) {
        continue;
      }
      let li = this.loader.buildPlaceholderElement();
      this.list.appendChild(li);
      this.items[i].element = li;
    }
  }
}

export default EndpointSliderItemProvider;
