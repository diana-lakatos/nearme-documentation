// @flow

const DEFAULT_ITEMS_PER_PAGE = 4;
const MINIMUM_ITEMS_COUNT = 4;

const truncate = require('lodash/truncate');

class CommentEndpointLoader implements EndpointLoader {
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
    return `/latest-projects.json?since=${since}&page=${page}&per_page=${perPage}`;
  }

  buildPlaceholderElement(): HTMLElement {
    let li = document.createElement('li');
    li.classList.add('loading');
    li.innerHTML = `
      <article class="card-a" aria-hidden="true">
        <figure><span class="placeholder"></span></figure>
        <ul class="numbers">
          <li>Comments <span>Loading...</span></li>
          <li>Followers <span>Loading...</span></li>
        </ul>
        <h3 class="hx">Loading</h3>
        <p class="user">Loading...</p>
        <div class="action"></div>
      </article>
    `;

    return li;
  }

  parseTotalEntriesResponse(data: TransactableEndpointResponseType): Promise<number> {
    return Promise.resolve(Math.max(data.projects.total_entries, MINIMUM_ITEMS_COUNT));
  }

  parseEndpointData(
    data: TransactableEndpointResponseType
  ): Promise<Array<TransactableEndpointResponseItemType>> {
    return Promise.resolve(data.projects.items);
  }

  populatePlaceholderElement(item: SliderItemType, data: TransactableEndpointResponseItemType) {
    let el = item.element;
    if (!(el instanceof HTMLElement)) {
      throw new Error('Missing placeholder for Slider item');
    }
    let lastComment = data.last_comment.items.pop();

    el.innerHTML = `
      <article class="card-a" data-transactable-last-comment-date="${lastComment ? lastComment.created_at : ''}">
        <figure><a href="${data.creator.profile_path}"><img src="${data.cover_photo.url}" /></a></figure>

        <ul class="numbers">
          <li>Comments <span>${data.comments.count}</span></li>
          <li>Followers <span data-followers-count="Transactable:${data.id}">${data.followers.total_entries}</span></li>
        </ul>

        <h3 class="hx">
          <a href="${data.show_path}">${truncate(data.title, { length: 40 })}</a>
        </h3>
        <p class="user"><a href="${data.creator.profile_path}"><img src="${data.creator.avatar.url}" width="30" height="30" />${data.creator.name}</a></p>
      </article>
    `;
    el.classList.remove('loading');
    item.loaded = true;
  }

  afterLoadedCallback(el: HTMLElement) {}
}

module.exports = CommentEndpointLoader;
