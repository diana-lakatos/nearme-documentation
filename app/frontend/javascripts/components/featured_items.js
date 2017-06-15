// @flow

class FeaturedItems {
  loader: HTMLElement;
  url: string;

  constructor(loader: HTMLElement) {
    this.loader = loader;
    this.url = loader.dataset.url;
    if (!this.url) {
      throw new Error('Missing URL for loading featured items listing');
    }

    this.initialize();
  }

  load(): Promise<string> {
    return new Promise((resolve, reject) => {
      let request = new XMLHttpRequest();

      request.open('GET', this.url, true);
      request.setRequestHeader('Accept', 'text/html');
      request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');

      request.onload = function() {
        if (request.status >= 200 && request.status < 400) {
          resolve(request.responseText);
        } else {
          reject(`Featured items loading error: ${request.responseText}`);
        }
      };

      request.onerror = function() {
        reject('Unable to load featured items listing from the server');
      };

      request.send();
    });
  }

  initialize() {
    this.load().then(this.updateHTML.bind(this)).catch((err: string) => {
      throw new Error(err);
    });
  }

  updateHTML(html: string) {
    this.loader.insertAdjacentHTML('afterend', html);
    if (this.loader.parentNode instanceof HTMLElement) {
      this.loader.parentNode.removeChild(this.loader);
    }

    $(document).trigger('rendered-favoritable-items.nearme');
  }
}

module.exports = FeaturedItems;
