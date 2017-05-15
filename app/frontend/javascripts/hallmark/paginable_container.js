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
    this.sortControl = container.querySelector('form.sort-form select[name="[sort]"]');

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
      this.sortForm.addEventListener('change', this.reorderResults.bind(this), true);
    }
  }

  reorderResults() {
    $(this.sortForm).submit();
    let url = this.sortForm.getAttribute('action');
    if (!url) {
      throw new Error('Missing action in the sort-form');
    }

    url = this.updatePageNumberInUrl(url, 1);
    url = this.updateSortOrderInUrl(url);

    this.updateResults(url);
  }

  updatePageNumberInUrl(url, pageNumber) {
    if (/page=/i.test(url)) {
      url = url.replace(/page=\d/, `page=${pageNumber}`);
    } else {
      url = url + `&page=${pageNumber}`;
    }

    return url;
  }

  updateSortOrderInUrl(url) {
    if (!this.sortControl) {
      return url;
    }

    let sortType = this.sortControl.value;
    if (/sort=/i.test(url)) {
      url = url.replace(/sort=[\w ]*/, `sort=${sortType}`);
    } else {
      url = url + `&sort=${sortType}`;
    }

    return url;
  }

  getMoreResultsUrl() {
    let nextPage = parseInt(this.seeMoreTrigger.dataset.nextPage, 10);
    if (!nextPage || nextPage < 2) {
      throw new Error('Invalid next page parameter');
    }

    let url = this.seeMoreTrigger.dataset.url;
    if (!url) {
      throw new Error('Missing URL attribute for fetching more results');
    }

    url = this.updatePageNumberInUrl(url, nextPage);
    url = this.updateSortOrderInUrl(url);

    return url;
  }

  updateResults(url) {
    this.disableMoreTrigger();

    $.ajax({
      url: url,
      dataType: 'json'
    })
      .done(this.processResults.bind(this))
      .fail(() => {
        this.enableMoreTrigger();
        throw new Error('Unable to fetch more results');
      });
  }

  loadMoreResults() {
    this.updateResults(this.getMoreResultsUrl());
  }

  processResults(results) {
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
      this.seeMoreTrigger.classList.remove('hidden');
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
