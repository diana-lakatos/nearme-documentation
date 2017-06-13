// @flow
class FacebookThumbnailService implements ThumbnailService {
  videoId: string;

  constructor(url: string) {
    this.videoId = this.getVideoIdFromUrl(url);
  }

  getVideoIdFromUrl(url: string): string {
    let matches = url.match(/\/videos\/([0-9]+)/);
    if (!matches) {
      throw new Error(`Unable to fetch video ID from provided url: ${url}`);
    }

    return matches[1];
  }

  getStorageId(): string {
    return `facebookThumbnail${this.videoId}`;
  }

  getThumbnailUrl(): Promise<string> {
    return Promise.resolve(`https://graph.facebook.com/${this.videoId}/picture`);
  }

  getPreviewContent(): Promise<ThumbnailServicePreviewContentType> {
    return Promise.resolve({
      html: `<div class="fb-video" data-href="https://www.facebook.com/facebook/videos/${this.videoId}/"
              data-autoplay="true"
              data-width="1280"
              data-height="720"
              data-allowfullscreen="true"
              >`,
      callback: (container: HTMLElement) => {
        window.FB.XFBML.parse(container);
      }
    });
  }
}

export default FacebookThumbnailService;
