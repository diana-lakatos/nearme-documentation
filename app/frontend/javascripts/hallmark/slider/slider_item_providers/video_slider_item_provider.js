// @flow
import type Thumbnail from '../thumbnails/thumbnail';
import ThumbnailFactory from '../thumbnails/thumbnail_factory';
const THUMBNAIL_SELECTOR = '[data-slider-thumbnail]';

class VideoSliderItemProvider implements SliderItemProvider {
  container: HTMLElement;
  thumbnails: Array<Thumbnail>;

  constructor(el: HTMLElement) {
    this.container = el;
    this.thumbnails = this.initThumbnails();
  }

  load(startIndex: number, endIndex: ?number): Promise<any> {
    endIndex = endIndex || startIndex + 1;
    let ps = this.thumbnails
      .slice(startIndex, endIndex)
      .map((thumbnail: Thumbnail): Promise<void> => thumbnail.load());
    return Promise.all(ps);
  }

  initThumbnails(): Array<Thumbnail> {
    let links = this.container.querySelectorAll(THUMBNAIL_SELECTOR);
    return Array.prototype.map.call(links, (link: HTMLLinkElement): Thumbnail => {
      return ThumbnailFactory.get(link);
    });
  }

  getTotalSlidesCount(): Promise<number> {
    return Promise.resolve(this.thumbnails.length);
  }
}

module.exports = VideoSliderItemProvider;
