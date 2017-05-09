const PROCESSING_LABEL = 'Loading&hellip;';

class PaginableContainer {
  constructor(container) {
    this.container = container;
    this.contentContainer = container.querySelector('.content-container');

    this.seeMoreTrigger = container.querySelector('[data-see-more] button');
    if (this.seeMoreTrigger) {
      this.seeMoreTriggerInitialLabel = this.seeMoreTrigger.innerHTML;
    }

    this.sortForm = container.querySelector('form.sort-form');
    this.sortControl = container.querySelector('form.sort-form [name="sort"]');

    this.bindEvents();
  }

  bindEvents() {
    if (this.seeMoreTrigger) {
      this.seeMoreTrigger.addEventListener('click', event => {
        event.preventDefault();
        this.loadMoreResults();
      });
    }

    if (this.sortForm) {
      this.sortForm.addEventListener(
        'change',
        this.reorderResults.bind(this),
        true
      );
    }
  }

  reorderResults() {
    this.sortForm.submit();
  }

  getResultsUrl() {
    let nextPage = parseInt(this.seeMoreTrigger.dataset.nextPage, 10);
    if (!nextPage || nextPage < 2) {
      throw new Error('Invalid next page parameter');
    }

    let moreUrl = this.seeMoreTrigger.dataset.url;
    if (!moreUrl) {
      throw new Error('Missing URL attribute for fetching more results');
    }

    if (/page=/i.test(moreUrl)) {
      moreUrl = moreUrl.replace(/page=\d/, `page=${nextPage}`);
    } else {
      moreUrl = moreUrl + `&page=${nextPage}`;
    }

    if (this.sortControl) {
      let sortType = this.sortControl.value;

      if (/sort=/i.test(moreUrl)) {
        moreUrl = moreUrl.replace(/sort=[\w ]*/, `sort=${sortType}`);
      } else {
        moreUrl = moreUrl + `&sort=${sortType}`;
      }
    }

    return moreUrl;
  }

  loadMoreResults() {
    this.disableMoreTrigger();

    $.ajax({
      url: this.getResultsUrl(),
      dataType: 'json'
    })
      .done(this.processMoreResults.bind(this))
      .fail((jqXHR, textStatus, errorThrown) => {
        this.enableMoreTrigger();
        throw new Error('Unable to fetch more results');
      });
  }

  processMoreResults(results) {
    // update results
    if (results.append) {
      this.contentContainer.insertAdjacentHTML('beforeend', results.content);
    } else {
      this.contentContainer.innerHTML = results.content;
    }

    // hide or update more trigger
    if (!results.next_page) {
      this.seeMoreTrigger.classList.add('hidden');
    } else {
      this.seeMoreTrigger.dataset.nextPage = results.next_page + '';
    }

    // reinitialize
    $(document).trigger('activity-feed-next-page');

    // unblock more button
    this.enableMoreTrigger();
  }

  enableMoreTrigger() {
    this.seeMoreTrigger.removeAttribute('disabled');
    this.seeMoreTrigger.innerHTML = this.seeMoreTriggerInitialLabel;
  }

  disableMoreTrigger() {
    this.seeMoreTrigger.setAttribute('disabled', 'disabled');
    this.seeMoreTrigger.innerHTML = PROCESSING_LABEL;
  }
}

module.exports = PaginableContainer;
