// @flow
import Thumbnail from './thumbnail';
import YoutubeThumbnailService from './youtube_thumbnail_service';
import FacebookThumbnailService from './facebook_thumbnail_service';
import VimeoThumbnailService from './vimeo_thumbnail_service';

class ThumbnailFactory {
  static get(link: HTMLLinkElement): Thumbnail {
    let url = link.getAttribute('href');
    if (!url) {
      throw new Error('Link is missing href attribute');
    }

    if (url.indexOf('youtube.com/') > -1) {
      return new Thumbnail(link, new YoutubeThumbnailService(url));
    }

    if (url.indexOf('vimeo.com/') > -1) {
      return new Thumbnail(link, new VimeoThumbnailService(url));
    }

    if (url.indexOf('facebook.com/') > -1) {
      return new Thumbnail(link, new FacebookThumbnailService(url));
    }

    throw new Error(`Unsupported thumbnail url format: ${url}`);
  }
}

export default ThumbnailFactory;
