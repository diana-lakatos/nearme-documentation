const Events = require('minivents/dist/minivents.commonjs');
const UserEntryImage = require('./user_entry_image');

class UserEntryImages {
  constructor(container) {
    Events(this);
    this.ui = {};
    this.ui.container = container;
    this.images = this.getImagesFromContainer();
    this.bindEvents();
    this.ui.removeField = container.querySelector('[data-user-entry-form-remove-input]');
  }

  getImagesFromContainer() {
    return Array.prototype.map.call(this.ui.container.querySelectorAll('[data-user-entry-form-image]'), (imageContainer) => {
      let image = new UserEntryImage({
        isPersisted: true
      });
      image.setContainer(imageContainer);
      return image;
    });
  }

  add({ dataUrl, orientation }) {
    let image = new UserEntryImage();
    image.setSource(dataUrl);
    if (orientation > 0) {
      image.setOrientation(orientation);
    }

    image.build();
    this.bindImageEvents(image);
    this.images.push(image);
    this.ui.container.insertAdjacentElement('afterbegin', image.getContainer());

    this.unmarkRemoval();
  }

  removeAll() {
    this.images.forEach((image) => {
      image.destroy();
    });

    this.markRemoval();
  }

  bindImageEvents(image) {
    image.on('remove', () => {
      this.emit('remove');
      this.markRemoval();
    });
  }

  bindEvents() {
    this.images.forEach((image) => {
      this.bindImageEvents(image);
    });
  }

  rollback() {
    this.images.forEach((image) => {
      image.rollback();
    });
    this.unmarkRemoval();
  }

  markRemoval() {
    if (this.ui.removeField) {
      this.ui.removeField.value = 1;
    }
  }

  unmarkRemoval() {
    if (this.ui.removeField) {
      this.ui.removeField.value = '';
    }
  }
}

module.exports = UserEntryImages;
