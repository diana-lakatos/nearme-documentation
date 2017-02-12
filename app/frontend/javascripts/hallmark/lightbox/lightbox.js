let PhotoSwipe = require('photoswipe/dist/photoswipe.js');
let PhotoSwipeUI_Default = require('photoswipe/dist/photoswipe-ui-default.js');
let template = require('raw-loader!./lightbox.template');

let defaults = {
  showHideOpacity: true,
  getThumbBoundsFn: false,
  shareEl: false
};

class Lightbox {
  constructor(options = {}) {
    this.pswpElement = this.getContainer();
    this.options = Object.assign({}, defaults, options);
  }

  open(index = 0) {
    let options = Object.assign({}, this.options);
    options.index = index;

    let gallery = new PhotoSwipe(this.pswpElement, PhotoSwipeUI_Default, this.items, options);
    gallery.init();
  }

  getContainer() {
    let el = document.querySelector('.pswp');
    if (el) {
      return el;
    }
    document.body.insertAdjacentHTML('beforeend', template);

    return document.querySelector('.pswp');
  }

  setItems(items) {
    this.items = items;
  }

  static getThumbnailBounds(thumbnail) {
    /* get window scroll Y */
    let pageYScroll = window.pageYOffset || document.documentElement.scrollTop;

    /* get position of element relative to viewport */
    let rect = thumbnail.getBoundingClientRect();

    return {
      x: rect.left,
      y: rect.top + pageYScroll,
      w: rect.width
    };
  }
}

module.exports = Lightbox;
