// @flow

import Eventable from '../../toolkit/eventable';
import UserEntryImage from './user_entry_image';

const REMOVE_FIELD_SELECTOR = '[data-user-entry-form-remove-input]';
const ENTRY_FORM_IMAGE_SELECTOR = '[data-user-entry-form-image]';

class UserEntryImages extends Eventable {
  container: HTMLElement;
  images: Array<UserEntryImage>;
  removeField: ?HTMLInputElement;

  constructor(container: HTMLElement) {
    super();

    this.container = container;
    this.images = this.getImagesFromContainer();
    this.bindEvents();
    let removeField = container.querySelector(REMOVE_FIELD_SELECTOR);
    if (removeField instanceof HTMLInputElement) {
      this.removeField = removeField;
    }
  }

  getImagesFromContainer(): Array<UserEntryImage> {
    let els = this.container.querySelectorAll(ENTRY_FORM_IMAGE_SELECTOR);

    return Array.prototype.map.call(
      els,
      (imageContainer: HTMLElement): UserEntryImage => {
        let image = new UserEntryImage({
          isPersisted: true
        });
        image.setContainer(imageContainer);
        return image;
      }
    );
  }

  add({ dataUrl, orientation }: { dataUrl: string, orientation: number }) {
    let image = new UserEntryImage();
    image.setSource(dataUrl);
    if (orientation > 0) {
      image.setOrientation(orientation);
    }

    image.build();
    this.bindImageEvents(image);
    this.images.push(image);
    this.container.insertAdjacentElement('afterbegin', image.getContainer());

    this.unmarkRemoval();
  }

  removeAll() {
    this.images.forEach((image: UserEntryImage) => {
      image.destroy();
    });

    this.markRemoval();
  }

  bindImageEvents(image: UserEntryImage) {
    image.on('remove', () => {
      this.emit('remove');
      this.markRemoval();
    });
  }

  bindEvents() {
    this.images.forEach((image: UserEntryImage) => {
      this.bindImageEvents(image);
    });
  }

  rollback() {
    this.images.forEach((image: UserEntryImage) => {
      image.rollback();
    });
    this.unmarkRemoval();
  }

  markRemoval() {
    if (this.removeField instanceof HTMLInputElement) {
      this.removeField.value = '1';
    }
  }

  unmarkRemoval() {
    if (this.removeField instanceof HTMLInputElement) {
      this.removeField.value = '';
    }
  }
}

module.exports = UserEntryImages;
