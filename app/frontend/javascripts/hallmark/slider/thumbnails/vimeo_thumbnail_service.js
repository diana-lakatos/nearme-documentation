// @flow
import { jsonp } from '../../../toolkit/url';
type VimeoApiType = {
  thumbnail_large: string,
  thumbnail_small: string,
  thumbnail_medium: string
};

type VimeoOembedApiType = {
  html: string
};

class VimeoThumbnailService implements ThumbnailService {
  videoId: string;
  url: string;

  constructor(url: string) {
    this.url = url;
    this.videoId = this.getVideoIdFromUrl(url);
  }

  getVideoIdFromUrl(url: string): string {
    let matches = url.match(/https?:\/\/(www\.)?vimeo\.com\/([0-9]+)/);
    if (!matches) {
      throw new Error(`Unable to fetch video ID from provided url: ${url}`);
    }

    return matches[2];
  }

  getStorageId(): string {
    return `vimeoThumbnail${this.videoId}`;
  }

  getThumbnailUrl(): Promise<string> {
    let url = `http://vimeo.com/api/v2/video/${this.videoId}.json`;

    return new Promise((resolve, reject) => {
      jsonp(url)
        .then((data: Array<VimeoApiType>) => {
          if (!data[0]) {
            reject(`Unable to fetch data from ${url}`);
            return;
          }
          resolve(data[0].thumbnail_large);
        })
        .catch(() => {
          console.log(`Unable to fetch data from ${url}`);
          reject();
        });
    });
  }

  getPreviewContent(): Promise<string> {
    let url = `https://vimeo.com/api/oembed.json?url=${escape(this.url)}&autoplay=1`;

    return new Promise((resolve, reject) => {
      jsonp(url)
        .then((data: VimeoOembedApiType) => {
          resolve(unescape(data.html));
        })
        .catch(reject);
    });
  }
}

export default VimeoThumbnailService;
