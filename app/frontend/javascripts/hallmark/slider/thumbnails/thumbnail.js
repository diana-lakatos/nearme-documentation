// @flow
import Preview from './preview';

class Thumbnail {
  link: HTMLLinkElement;
  url: string;
  loadPromise: Promise<*>;
  service: ThumbnailService;

  constructor(link: HTMLLinkElement, service: ThumbnailService) {
    this.link = link;

    let url = link.getAttribute('href');
    if (!url) {
      throw new Error('Thumbnail link is missing href attribute');
    }
    this.url = url;
    this.service = service;

    this.bindEvents();
  }

  bindEvents() {
    this.link.addEventListener('click', (e: Event) => {
      e.preventDefault();
      this.openPreview();
    });
  }

  openPreview() {
    let preview = new Preview();
    preview.open();
    this.service.getPreviewContent().then((content: ThumbnailServicePreviewContentType) => {
      if (typeof content === 'string') {
        preview.setContent(content);
        return;
      }
      preview.setContent(content.html);
      content.callback(preview.getContainer());
    });
  }

  setThumbnailUrl(url: string) {
    this.link.style.backgroundImage = `url(${url})`;
  }

  load(): Promise<void> {
    if (this.loadPromise) {
      return this.loadPromise;
    }
    this.loadPromise = this.getLoadPromise();
    return this.loadPromise;
  }

  /* This method should be overwritten with specific method for loading thumbnail image */
  getLoadPromise(): Promise<*> {
    return new Promise(resolve => {
      let stored = localStorage.getItem(this.service.getStorageId());
      if (stored) {
        this.setThumbnailUrl(stored);
        resolve();
        return;
      }

      this.service
        .getThumbnailUrl()
        .then((url: string) => {
          localStorage.setItem(this.service.getStorageId(), url);
          this.setThumbnailUrl(url);
          resolve();
        })
        .catch(() => {
          throw new Error('Unable to retrieve thumbnail URL');
        });
    });
  }
}

export default Thumbnail;
