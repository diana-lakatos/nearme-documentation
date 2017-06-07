// @flow
const Gallery = require('../../gallery/gallery');

const DEFAULT_ITEMS_PER_PAGE = 4;
const MINIMUM_ITEMS_COUNT = 4;

class PhotoEndpointLoader implements EndpointLoader {
  getObjectsCountInOneSlide(): number {
    return 1;
  }
  getDefaultItemsPerPageCount(): number {
    return DEFAULT_ITEMS_PER_PAGE;
  }
  getMinimumItemsCount(): number {
    return MINIMUM_ITEMS_COUNT;
  }
  getEndpointUrl(since: number, page: number, perPage: number): string {
    return `/latest-photos.json?since=${since}&page=${page}&per_page=${perPage}`;
  }
  buildPlaceholderElement(): HTMLElement {
    let li = document.createElement('li');
    li.classList.add('loading');
    li.innerHTML = `
      <span class="placeholder"></span>
      <p class="user">Loading...</p>
    `;

    return li;
  }

  parseTotalEntriesResponse(data: PhotoEndpointResponseType): Promise<number> {
    return Promise.resolve(Math.max(data.photos.total_entries, MINIMUM_ITEMS_COUNT));
  }

  parseEndpointData(
    data: PhotoEndpointResponseType
  ): Promise<Array<PhotoEndpointResponseItemType>> {
    return Promise.resolve(data.photos.items);
  }

  populatePlaceholderElement(item: SliderItemType, photo: PhotoEndpointResponseItemType) {
    let el = item.element;
    if (!(el instanceof HTMLElement)) {
      throw new Error('Missing placeholder for Slider item');
    }
    el.innerHTML = `
      <a href="${photo.image.large}" class="thumbnail" data-original-width="${photo.image.image_original_width}" data-original-height="${photo.image.image_original_height}"><img src="${photo.image.thumb}"></a>
      <p class="user"><a href="${photo.creator.profile_path}"><img src="${photo.creator.avatar.url}" width="30" height="30" />${photo.creator.name}</a></p>
    `;
    el.classList.remove('loading');
    item.loaded = true;
  }

  afterLoadedCallback(element: HTMLElement) {
    new Gallery(element, 'a.thumbnail');
  }
}

module.exports = PhotoEndpointLoader;
