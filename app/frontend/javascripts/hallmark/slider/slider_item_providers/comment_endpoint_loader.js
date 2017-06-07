// @flow

const COMMENTS_PER_SLIDE = 4;
const DEFAULT_ITEMS_PER_PAGE = 2;
const MINIMUM_ITEMS_COUNT = 2;

const truncate = require('lodash/truncate');
const chunk = require('lodash/chunk');

class CommentEndpointLoader implements EndpointLoader {
  getObjectsCountInOneSlide(): number {
    return COMMENTS_PER_SLIDE;
  }

  getDefaultItemsPerPageCount(): number {
    return DEFAULT_ITEMS_PER_PAGE;
  }

  getMinimumItemsCount(): number {
    return MINIMUM_ITEMS_COUNT;
  }

  getEndpointUrl(since: number, page: number, perPage: number): string {
    return `/latest-comments.json?since=${since}&page=${page}&per_page=${perPage}`;
  }

  buildPlaceholderElement(): HTMLElement {
    let li = document.createElement('li');
    li.classList.add('loading');
    // repeat 4 times
    li.innerHTML = Array(5).join(`
       <article class="loading" aria-hidden="true">
        <figure class="avatar"></figure>
        <h3 class="hx">Loading comment info...</h3>
        <p>Loading comment body...</p>
      </article>
    `);

    return li;
  }

  parseTotalEntriesResponse(data: CommentEndpointResponseType): Promise<number> {
    let totalCount = Math.max(
      Math.ceil(data.comments.total_entries / COMMENTS_PER_SLIDE),
      MINIMUM_ITEMS_COUNT
    );
    return Promise.resolve(totalCount);
  }

  parseEndpointData(
    data: CommentEndpointResponseType
  ): Promise<Array<Array<CommentEndpointResponseItemType>>> {
    return Promise.resolve(chunk(data.comments.items, COMMENTS_PER_SLIDE));
  }

  populatePlaceholderElement(item: SliderItemType, data: Array<CommentEndpointResponseItemType>) {
    let el = item.element;
    if (!(el instanceof HTMLElement)) {
      throw new Error('Missing placeholder for Slider item');
    }

    let output = data.reduce((acc: string, comment: CommentEndpointResponseItemType): string => {
      let hasAttachment = !!comment.activity_feed_images.full;
      let truncateValue = hasAttachment ? 90 : 110;

      let attachmentString = hasAttachment
        ? `<a href="${comment.activity_feed_images.full || ''}" class="attachment"><img src="${comment.activity_feed_images.thumb || ''}" alt="Post attachment miniature"></a>`
        : '';
      return (
        acc +
        `
          <article${hasAttachment ? ' class="has-attachment"' : ''}>
            <figure class="avatar"><a href="${comment.creator.profile_path}"><img src="${comment.creator.avatar.url}"></a></figure>
            <h3 class="hx"><a href="${comment.creator.profile_path}">${comment.creator.name}</a> posted on <a href="${comment.commentable.url}">${comment.commentable.name}</a></h3>
            <p>${truncate(comment.body, { length: truncateValue })}</p>
            ${attachmentString}
          </article>`
      );
    }, '');

    el.innerHTML = output;
    el.classList.remove('loading');
    item.loaded = true;
  }

  afterLoadedCallback(el: HTMLElement) {}
}

module.exports = CommentEndpointLoader;
