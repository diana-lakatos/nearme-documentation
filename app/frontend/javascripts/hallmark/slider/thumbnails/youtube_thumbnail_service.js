// @flow
import { parseUrl } from '../../../toolkit/url';

class YoutubeThumbnailService implements ThumbnailService {
  videoId: string;

  constructor(url: string) {
    this.videoId = this.getVideoIdFromUrl(url);
  }

  getVideoIdFromUrl(url: string): string {
    let parser = parseUrl(url);

    if (!parser) {
      throw new Error(`Unable to parse provided URL: ${url}`);
    }

    let videoId = parser.search.split('&')[0].split('v=')[1];
    if (!videoId) {
      throw new Error(`Unable to fetch video ID from provided url: ${url}`);
    }
    return videoId;
  }

  getStorageId(): string {
    return `youtubeVideo${this.videoId}`;
  }

  getThumbnailUrl(): Promise<string> {
    return Promise.resolve(`https://img.youtube.com/vi/${this.videoId}/hqdefault.jpg`);
  }

  getPreviewContent(): Promise<string> {
    let html = `<iframe id="ytplayer" type="text/html"
                src="http://www.youtube.com/embed/${this.videoId}?autoplay=1&controls=2&fs=1&modestbranding=1&rel=0&showinfo=0"
                frameborder="0"/>`;

    return Promise.resolve(html);
  }
}

export default YoutubeThumbnailService;
