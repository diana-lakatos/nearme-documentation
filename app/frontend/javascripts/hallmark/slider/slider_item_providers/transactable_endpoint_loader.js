// @flow

const MINIMUM_SLIDES_PER_PAGE = 4;
const CUTOFF_PERIOD = 7 * 24 * 60 * 60 * 1000; // one week
const LABEL_CLASS = 'new-comments-label';

const FOLLOW_URL = '/follow';
const UNFOLLOW_URL = '/unfollow';
const FOLLOW_LABEL = 'Follow';
const UNFOLLOW_LABEL = 'Unfollow';
const PROCESSING_LABEL = 'Processing&hellip;';
const FOLLOW_BUTTON_CLASS = 'tiny';

const truncate = require('lodash/truncate');

class CommentEndpointLoader implements EndpointLoader {
  currentUserId: ?number;

  getObjectsCountInOneSlide(): number {
    return 1;
  }

  getMinimumSlidesPerPageCount(): number {
    return MINIMUM_SLIDES_PER_PAGE;
  }

  getEndpointUrl(page: number, perPage: number, since: ?number): string {
    let url = `/latest-projects.json?page=${page}&per_page=${perPage}`;
    if (since) {
      url = `${url}&since=${since}`;
    }
    return url;
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

  parseTotalSlidesCountResponse(data: TransactableEndpointResponseType): Promise<number> {
    return Promise.resolve(Math.max(data.projects.total_entries, MINIMUM_SLIDES_PER_PAGE));
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
        <div class="action">
        ${this.getFollowButton(data.id, data.creator.id, data.is_followed)}
        </div>
      </article>
    `;
    el.classList.remove('loading');
    item.loaded = true;
  }

  getCurrentUserId(): ?number {
    if (typeof this.currentUserId !== 'undefined') {
      return this.currentUserId;
    }

    let body = document.querySelector('body');
    if (!(body instanceof HTMLElement)) {
      throw new Error('Invalid context, missing document body');
    }
    this.currentUserId = parseInt(body.dataset.cid, 10);
    return this.currentUserId;
  }

  getFollowButton(transactableId: number, creatorId: number, isFollowed: boolean): string {
    let actionUrl, followClass, actionMethod, buttonLabel, followState;
    if (creatorId === this.getCurrentUserId()) {
      return '';
    }

    if (!this.getCurrentUserId()) {
      return `<a href="/users/sign_in?return_to=%2F%3Fhome%3D1" class="button-a action--follow ${FOLLOW_BUTTON_CLASS}">Follow</a>`;
    }

    if (isFollowed) {
      actionUrl = UNFOLLOW_URL;
      followClass = 'action--unfollow';
      actionMethod = 'delete';
      buttonLabel = UNFOLLOW_LABEL;
      followState = 'true';
    } else {
      actionUrl = FOLLOW_URL;
      followClass = 'action--follow';
      actionMethod = 'post';
      buttonLabel = FOLLOW_LABEL;
      followState = 'false';
    }

    return `<form action="${actionUrl}"
          method="post"
          data-follow-button-form
          data-follow-state="${followState}"
          data-follow-url="${FOLLOW_URL}"
          data-follow-label="${FOLLOW_LABEL}"
          data-unfollow-url="${UNFOLLOW_URL}"
          data-unfollow-label="${UNFOLLOW_LABEL}"
          data-followers-counter-id="Transactable:${transactableId}">
      <input type="hidden" name="type" value="Transactable">
      <input type="hidden" name="id" value="${transactableId}">
      <input type="hidden" name="_method" value="${actionMethod}" data-method>
      <button type="submit" class="button-a ${followClass} ${FOLLOW_BUTTON_CLASS}" data-disable-with="${PROCESSING_LABEL}">${buttonLabel}</button>
    </form>`;
  }

  getLastCommentDate(dateString?: string): Date | void {
    if (!dateString) {
      return;
    }

    let timestamp = Date.parse(dateString);

    if (isNaN(timestamp)) {
      throw new Error(`Unable to parse provided date string: ${dateString}`);
    }

    return new Date(timestamp);
  }

  checkCommentCutoffPeriod(date: Date): boolean {
    let now = new Date();
    return date.getTime() > now.getTime() - CUTOFF_PERIOD;
  }

  newCommentsLabel(container: HTMLElement) {
    let lastCommentDate = this.getLastCommentDate(container.dataset.transactableLastCommentDate);

    if (lastCommentDate && this.checkCommentCutoffPeriod(lastCommentDate)) {
      let anchor = container.querySelector('ul.numbers li');
      if (!(anchor instanceof HTMLElement)) {
        throw new Error('Missing comments anchor element');
      }

      anchor.insertAdjacentHTML('beforeend', `<span class="${LABEL_CLASS}">New</span>`);
    }
  }

  afterLoadedCallback(element: HTMLElement) {
    let article = element.querySelector('article');
    if (!(article instanceof HTMLElement)) {
      throw new Error('Unable to locate article element');
    }
    this.newCommentsLabel(article);
  }
}

module.exports = CommentEndpointLoader;
