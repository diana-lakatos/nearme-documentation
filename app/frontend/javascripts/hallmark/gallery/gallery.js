let PhotoSwipe = require('photoswipe/dist/photoswipe.js');
let PhotoSwipeUI_Default = require('photoswipe/dist/photoswipe-ui-default.js');
let template = require('raw-loader!./gallery.template');
let defaults = {
  showHideOpacity: true,
  // getThumbBoundsFn: false,
  shareEl: false
};


class Gallery {
  constructor(wrapper){
    this.wrapper = wrapper;
    this.pswpElement = this.getGalleryContainer();
    this.photoElements = wrapper.querySelectorAll('a');

    this.items = this.parsePhotosHTML(this.photoElements);
    this.bindEvents();
  }

  parsePhotosHTML(photoElements) {
    return Array.prototype.map.call(photoElements, (photo)=> {
      return {
        src: photo.href,
        w: parseInt(photo.dataset.originalWidth, 10),
        h: parseInt(photo.dataset.originalHeight, 10)
      };
    });
  }

  getGalleryContainer(){
    let el = document.querySelector('.pswp');
    if (el) {
      return el;
    }
    document.body.insertAdjacentHTML('beforeend', template);

    return document.querySelector('.pswp');
  }

  bindEvents() {
    Array.prototype.forEach.call(this.photoElements, (photo, index)=> {
      photo.addEventListener('click', (e)=>{
        if (e.defaultPrevented) {
          return;
        }
        e.preventDefault();
        this.open(index);
      });
    });
  }

  open(index = 0) {
    let options = Object.assign({}, defaults);
    options.index = index;

    options.getThumbBoundsFn = this.getThumbBounds.bind(this);

    let gallery = new PhotoSwipe( this.pswpElement, PhotoSwipeUI_Default, this.items, options);
    gallery.init();
  }

  getThumbBounds(index) {
    /* find thumbnail element */
    let thumbnail = this.photoElements[index].querySelector('img');

    /* get window scroll Y */
    let pageYScroll = window.pageYOffset || document.documentElement.scrollTop;

    /* get position of element relative to viewport */
    let rect = thumbnail.getBoundingClientRect();

    return {
      x:rect.left,
      y: rect.top + pageYScroll,
      w: rect.width
    };
  }
}

module.exports = Gallery;
