// @flow
import Eventable from '../../toolkit/eventable';

const defaults = {
  isPersisted: false
};

class UserEntryImage extends Eventable {
  container: HTMLElement;
  image: ?HTMLImageElement;
  trigger: HTMLButtonElement;
  isPersisted: boolean;
  fileType: string;
  orientation: number;
  source: string;
  options: {
    isPersisted: boolean
  }

  constructor(options: { isPersisted?: boolean } = {}) {
    super();

    this.options = Object.assign({}, defaults, options);
    this.source = '';
    this.orientation = 1;
    this.fileType = 'image/jpg';
  }

  getContainer(): HTMLElement {
    return this.container;
  }

  setContainer(container: HTMLElement) {
    this.container = container;
    let image = container.querySelector('img');
    if (image instanceof HTMLImageElement) {
      this.image = image;
    }

    this.addRemoveTrigger();
    this.bindEvents();
  }

  setSource(source: string) {
    this.source = source;
    if (this.image instanceof HTMLImageElement) {
      this.image.setAttribute('src', source);
    }
  }

  setFileType(fileType: string) {
    this.fileType = fileType;
  }

  setOrientation(orientation: number) {
    if (orientation < 1 || orientation > 8) {
      throw new Error(`Invalid orientation value: ${orientation}`);
    }
    this.orientation = orientation;

    if (this.image instanceof HTMLImageElement) {
      this.applyOrientation();
    }
  }

  applyOrientation() {
    /* iOS seems to use the orientation data correctly when loading as base64 */
    let iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
    if (iOS) {
      return;
    }
    if (this.image) {
      this.image.className = `orientation-${this.orientation}`;
    }
  }

  build() {
    let container = document.createElement('div');
    container.classList.add('user-entry-form-image');
    container.setAttribute('data-user-entry-form-image', '');
    this.container = container;

    let image: HTMLImageElement = document.createElement('img');
    image.setAttribute('src', this.source);
    this.image = image;
    this.applyOrientation();

    this.container.appendChild(image);

    this.addRemoveTrigger();
    this.bindEvents();
  }

  addRemoveTrigger() {
    let trigger = document.createElement('button');
    trigger.setAttribute('type', 'button');
    trigger.classList.add('remove');
    trigger.innerText = 'Remove this image';
    this.trigger = trigger;
    this.container.appendChild(trigger);
  }

  bindEvents() {
    this.trigger.addEventListener('click', () => {
      this.destroy();
      this.emit('remove');
    });
  }

  destroy() {
    this.container.classList.add('hidden');
  }

  rollback() {
    if (this.options.isPersisted) {
      this.container.classList.remove('hidden');
    } else {
      this.container.classList.add('hidden');
    }
  }
}

module.exports = UserEntryImage;
