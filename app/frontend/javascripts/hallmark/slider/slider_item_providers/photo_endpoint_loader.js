// @flow
const Gallery = require('../../gallery/gallery');

const MINIMUM_SLIDES_PER_PAGE = 4;

class PhotoEndpointLoader implements EndpointLoader {
  getObjectsCountInOneSlide(): number {
    return 1;
  }

  getMinimumSlidesPerPageCount(): number {
    return MINIMUM_SLIDES_PER_PAGE;
  }

  getEndpointUrl(page: number, perPage: number, since: ?number): string {
    let url = `/latest-photos.json?page=${page}&per_page=${perPage}`;
    if (since) {
      url = `${url}&since=${since}`;
    }
    return url;
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

  parseTotalSlidesCountResponse(data: PhotoEndpointResponseType): Promise<number> {
    return Promise.resolve(Math.max(data.photos.total_entries, MINIMUM_SLIDES_PER_PAGE));
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
