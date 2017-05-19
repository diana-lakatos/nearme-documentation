const Lightbox = require('../lightbox/lightbox.js');

class Gallery {
  constructor(wrapper) {
    this.wrapper = wrapper;
    this.photoElements = wrapper.querySelectorAll('a');

    this.lightbox = this.initLightbox();
    this.bindEvents();
  }

  initLightbox() {
    let lightbox = new Lightbox({ getThumbBoundsFn: this.getThumbBounds.bind(this) });

    lightbox.setItems(this.parsePhotosHTML(this.photoElements));
    return lightbox;
  }

  parsePhotosHTML(photoElements) {
    return Array.prototype.map.call(photoElements, photo => {
      return {
        src: photo.href,
        w: parseInt(photo.dataset.originalWidth, 10),
        h: parseInt(photo.dataset.originalHeight, 10)
      };
    });
  }

  bindEvents() {
    Array.prototype.forEach.call(this.photoElements, (photo, index) => {
      photo.addEventListener('click', e => {
        if (e.defaultPrevented) {
          return;
        }
        e.preventDefault();
        this.lightbox.open(index);
      });
    });
  }

  getThumbBounds(index) {
    /* find thumbnail element */
    let thumbnail = this.photoElements[index].querySelector('img');
    return Lightbox.getThumbnailBounds(thumbnail);
  }
}

module.exports = Gallery;
