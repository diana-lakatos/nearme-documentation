const Events = require('minivents/dist/minivents.commonjs');

const defaults = {
  isPersisted: false
};

class UserEntryImage {
  constructor(options = {}) {
    Events(this);
    this.options = Object.assign({}, defaults, options);
    this.source = '';
    this.ui = {};
    this.orientation = 1;
    this.fileType = 'image/jpg';
  }

  getContainer() {
    return this.ui.container;
  }

  setContainer(container) {
    this.ui.container = container;
    this.ui.image = container.querySelector('img');

    this.addRemoveTrigger();
    this.bindEvents();
  }

  setSource(source) {
    this.source = source;
    if (this.ui.image) {
      this.ui.image.setAttribute('src', source);
    }
  }

  setFileType(fileType) {
    this.fileType = fileType;
  }

  setOrientation(orientation) {
    if (orientation < 1 || orientation > 8) {
      throw new Error(`Invalid orientation value: ${orientation}`);
    }
    this.orientation = orientation;
    if (this.ui.image) {
      this.applyOrientation();
    }
  }

  applyOrientation() {
    /* iOS seems to use the orientation data correctly when loading as base64 */
    let iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
    if (iOS) {
      return;
    }

    this.ui.image.className = `orientation-${this.orientation}`;
  }

  build() {
    let container = document.createElement('div');
    container.classList.add('user-entry-form-image');
    container.setAttribute('data-user-entry-form-image', '');
    this.ui.container = container;

    let image = document.createElement('img');
    image.setAttribute('src', this.source);
    this.ui.image = image;
    this.applyOrientation();

    this.ui.container.appendChild(this.ui.image);

    this.addRemoveTrigger();
    this.bindEvents();
  }

  addRemoveTrigger() {
    let trigger = document.createElement('button');
    trigger.setAttribute('type', 'button');
    trigger.classList.add('remove');
    trigger.innerText = 'Remove this image';
    this.ui.trigger = trigger;
    this.ui.container.appendChild(trigger);
  }

  bindEvents() {
    this.ui.trigger.addEventListener('click', () => {
      this.destroy();
      this.emit('remove');
    });
  }

  destroy() {
    this.ui.container.classList.add('hidden');
  }

  rollback() {
    if (this.isPersisted) {
      this.ui.container.classList.remove('hidden');
    } else {
      this.ui.container.classList.add('hidden');
    }
  }
}

module.exports = UserEntryImage;
