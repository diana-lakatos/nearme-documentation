// @flow
const Gallery = require('../../gallery/gallery');

const COMMENTS_PER_SLIDE = 8;
const MINIMUM_SLIDES_PER_PAGE = 1;

const truncate = require('lodash/truncate');
const chunk = require('lodash/chunk');

class CommentEndpointLoader implements EndpointLoader {
  getObjectsCountInOneSlide(): number {
    return COMMENTS_PER_SLIDE;
  }

  getMinimumSlidesPerPageCount(): number {
    return MINIMUM_SLIDES_PER_PAGE;
  }

  getEndpointUrl(page: number, perPage: number, since: ?number): string {
    let url = `/latest-comments.json?page=${page}&per_page=${perPage}`;
    if (since) {
      url = `${url}&since=${since}`;
    }
    return url;
  }

  buildPlaceholderElement(): HTMLElement {
    let li = document.createElement('li');
    li.classList.add('loading');

    let output = Array(COMMENTS_PER_SLIDE + 1).join(`
       <article class="loading" aria-hidden="true">
        <figure class="avatar"></figure>
        <h3 class="hx">Loading comment info...</h3>
        <p>Loading comment body...</p>
      </article>
    `);

    li.innerHTML = `<div class="comments-wrapper">${output}</div>`;

    return li;
  }

  parseTotalSlidesCountResponse(data: CommentEndpointResponseType): Promise<number> {
    let totalCount = Math.max(
      Math.ceil(data.comments.total_entries / COMMENTS_PER_SLIDE),
      MINIMUM_SLIDES_PER_PAGE
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
      let attachment = comment.activity_feed_images.shift();
      let truncateValue = 110;
      let attachmentString = '';

      if (attachment) {
        truncateValue = 90;
        attachmentString = `
        <a href="${attachment.full || ''}"
          class="attachment"
          data-original-width="${attachment.image_original_width}"
          data-original-height="${attachment.image_original_height}">
          <img src="${attachment.thumb || ''}" alt="Post attachment miniature">
        </a>`;
      }

      return (
        acc +
        `
          <article${attachment ? ' class="has-attachment"' : ''}>
            <figure class="avatar"><a href="${comment.creator.profile_path}"><img src="${comment.creator.avatar.url}"></a></figure>
            <h3 class="hx"><a href="${comment.creator.profile_path}">${comment.creator.name}</a> posted on <a href="${this.getCommentableUrl(comment.commentable.url)}">${comment.commentable.name}</a></h3>
            <p>${truncate(comment.body, { length: truncateValue })}</p>
            ${attachmentString}
          </article>`
      );
    }, '');

    el.innerHTML = `<div class="comments-wrapper">${output}</div>`;
    el.classList.remove('loading');
    item.loaded = true;
  }

  /* Modify commentable url for projects, as it needs additional anchor */
  getCommentableUrl(str: string): string {
    if (str.indexOf('/listings/') > -1) {
      str = `${str}#activity-tab`;
    }
    return str;
  }

  afterLoadedCallback(element: HTMLElement) {
    if (element.querySelector('a.attachment')) {
      new Gallery(element, 'a.attachment');
    }
  }
}

module.exports = CommentEndpointLoader;
