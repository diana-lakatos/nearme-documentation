// require 'jquery-ui/ui/sortable'
// require 'swipebox/src/js/jquery.swipebox'
// require 'imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.iframe-transport.js'
// require 'imports?define=>false&exports=>false!blueimp-file-upload/js/jquery.fileupload.js'

// require 'jquery-dragster/jquery.dragster'

import closest from '../../../toolkit/closest';
import xhr from '../../../toolkit/xhr';
import Dialog from '../../dialog';
let delegate = require('dom-delegate');

class ImageInput {
  constructor(input) {
    this._bound = {};
    this._delegated = {};
    this._ui = {};
    this._ui.input = input;
    this._ui.container = closest(this._ui.input, '.form-group');
    this._ui.form = closest(this._ui.input, 'form');
    this._ui.fieldWrapper = closest(this._ui.input, '.input-preview');
    this._ui.label = this._ui.container.querySelector('label');
    this._ui.collection = this._ui.container.querySelector('[data-image-collection]');

    this._delegated.container = delegate(this._ui.container);

    this._isMultiple = !!this._ui.input.getAttribute('multiple');
    this._isJsUpload = !!this._ui.input.dataset.uploadUrl;
    this._hasCaptions = !!this._ui.input.dataset.hasCaptions;
    this._captionPlaceholder = this._ui.input.dataset.captionPlaceholder;

    this._objectName = this._ui.input.dataset.objectName;
    this._modelName = this._ui.input.dataset.modelName;

    this._dropzoneLabel = this._ui.input.dataset.dropzoneLabel;
    this._uploadOnSaveLabel = this._ui.input.dataset.uploadOnSaveLabel;

    this._isSortable = this._ui.collection && !!this._ui.collection.dataset.sortable;

    this._allowedFileTypes = [ 'jpg', 'jpeg', 'gif', 'png' ];

    this._processing = 0;

    this._initializePreview();

    if (this._isSortable) {
      this._initializeSortable();
    }

    if (this._isJsUpload) {
      this._initializeFileUpload();
      this._initializeDraggable();
      this._initializeProgressbar();
    }

    this._bindEvents();
  }

  _bindEvents() {
    this._listenToDeletePhoto();
    this._listenToEditPhoto();
    this._listenToDragFile();
    this._listenToPreviewEvents();
    this._preventEarlySubmission();

    if (!this._isJsUpload && Modernizr.filereader) {
      this._listenToInputChange();
    }
  }

  _initializePreview() {
    let preview = document.createElement('div');
    preview.className = 'form-images__preview';
    preview.innerHTML = '<figure><img src=""></figure><span class="form-images__preview__close">Close preview</span>';
    this._ui.preview = preview;
    document.body.appendChild(this._ui.preview);
  }

  _showPreview(url) {
    this._ui.preview.querySelector('figure').innerHTML = `<img src='${url}'>`;
    this._ui.preview.classList.add('preview--active');

    this._bound.previewKeypress = e => {
      if (e.which === 27) {
        this._hidePreview();
      }
    };

    document.body.addEventListener('keydown', this._bound.previewKeypress);
  }

  _hidePreview() {
    this._ui.preview.classList.remove('preview--active');
    document.body.removeEventListener('keydown', this._bound.previewKeypress);
  }

  _listenToPreviewEvents() {
    this._ui.preview.addEventListener('click', () => {
      this._hidePreview();
    });

    this._delegated.container.on('click', '[data-action-preview]', (e, target) => {
      e.preventDefault();
      e.stopPropagation();
      let url = closest(target, 'a').getAttribute('href');
      this._showPreview(url);
    });
  }

  _validateFileType(file) {
    const types = this._allowedFileTypes.map(item => {
      return `image/${item}`;
    });

    return types.indexOf(file) > -1;
  }

  /* It will show the dropzone on file dragging to browser window */
  _listenToDragFile() {}

  _listenToDataUrlPreview() {
    this._delegated.container.on('click', 'action--dataurl-preview', (e, target) => {
      const src = closest(target, 'a').querySelector('img').getAttribute('src');
      this._showPreview(src);
    });
  }

  _listenToInputChange() {
    let reader = new FileReader();

    reader.onloadend = () => {
      this._updatePreview({ dataUrl: reader.result });
    };

    this._ui.input.addEventListener('change', e => {
      if (this._isMultiple) {
        throw new Error('Support for multiple files without XHR is not implemented');
      }

      let file = e.target.files[0];
      if (file) {
        reader.readAsDataURL(file);
      }
    });
  }

  _initializeDraggable() {
    this._ui.fieldWrapper.classList.add('draggable-enabled');

    this._ui.dropzone = document.createElement('div');
    this._ui.dropzone.classList.add('drop-zone');
    this._ui.dropzone.innerHTML = `<div class='text'>${this._dropzoneLabel}</div>`;
    this._ui.fieldWrapper.insertBefore(this._ui.dropzone, this._ui.fieldWrapper.firstChild);
  }

  _initializeProgressbar() {
    let progressBar = document.createElement('div');
    progressBar.classList.add('file-progress');
    progressBar.innerHTML = '<div class="bar"></div><div class="text"></div>';
    this._ui.fieldWrapper.insertBefore(progressBar, this._ui.fieldWrapper.firstChild);
    this._ui.uploadLabelContainer = this._ui.container.querySelector('.file-progress .text');
  }

  _initializeFileUpload() {}

  _updatePreview(data) {
    let preview = this._ui.fieldWrapper.querySelector('.preview');

    if (!preview) {
      preview = document.createElement('div');
      preview.classList = 'preview';
      this._ui.fieldWrapper.prepend(preview, this._ui.fieldWrapper.firstChild);
    }

    preview.innerHTML = '<figure></figure><div class="form-images__options"></div>';

    let options = preview.querySelector('.form-images__options');

    function createPreview(full_url, thumb_url) {
      let link = document.createElement('a');
      link.href = full_url;
      link.className = 'preview';
      link.setAttribute('data-action-preview', '');
      link.innerHTML = `<img src='${thumb_url}'>`;
      preview.querySelector('figure').appendChild(link);
    }

    if (data.hasOwnProperty('sizes')) {
      createPreview(data.sizes.full.url, data.sizes.space_listing.url);
    }

    if (data.hasOwnProperty('url')) {
      createPreview(data.url, data.url);
    }

    if (data.hasOwnProperty('dataUrl')) {
      createPreview(data.dataUrl, data.dataUrl);
    }

    if (data.hasOwnProperty('resize_url')) {
      options.appendChild(this._createEditButton(data.resize_url));
    }

    if (data.hasOwnProperty('destroy_url')) {
      options.appendChild(this._createRemoveButton(data.destroy_url));
    }

    if (!this._isJsUpload) {
      let uploadOnSaveLabel = document.createElement('small');
      uploadOnSaveLabel.innerHTML = this._uploadOnSaveLabel;
      preview.appendChild(uploadOnSaveLabel);
    }
  }

  _initializeSortable() {}

  _rebindEvents() {}

  _createEditButton(editUrl) {
    let editButton = document.createElement('button');
    editButton.type = 'button';
    editButton.className = 'action--edit';
    editButton.dataset.edit = '';
    editButton.dataset.url = editUrl;
    editButton.innerHTML = 'Crop & Resize';

    return editButton;
  }

  _createRemoveButton(removeUrl) {
    let removeButton = document.createElement('button');
    removeButton.type = 'button';
    removeButton.className = 'action--delete';
    removeButton.dataset.delete = '';
    removeButton.dataset.url = removeUrl;
    removeButton.dataset.labelConfirm = 'Are you sure you want to delete this image?';
    removeButton.innerHTML = 'Remove';

    return removeButton;
  }

  _createCollectionItem(data) {
    let container = document.createElement('li');
    container.dataset.photoItem = '';

    container.innerHTML = `<a href='${data.sizes.full.url}' class='preview' data-action-preview><img src='${data.sizes.space_listing.url}'></a>`;

    let options = document.createElement('div');
    options.className = 'form-images__options';
    container.appendChild(options);

    if (data.hasOwnProperty('resize_url')) {
      options.appendChild(this._createEditButton(data.resize_url));
    }

    if (data.hasOwnProperty('destroy_url')) {
      options.appendChild(this._createRemoveButton(data.destroy_url));
    }

    if (this._isSortable) {
      container.insertAdjacentHTML(
        'beforeend',
        `
                <span class='sort-handle'></span>
                <input type='hidden' name='${this._objectName}[${this._modelName}_ids][]' value='${data.id}'>")
                <input type='hidden' name='${this._objectName}[${this._modelName}s_attributes][${data.id}][id]' value='${data.id}'>")
                <input type='hidden' name='${this._objectName}[${this._modelName}s_attributes][${data.id}][position]' value='' class='photo-position-input'>`
      );
    }

    if (this._hasCaptions) {
      container.insertAdjacentHTML(
        'beforend',
        `<span class='caption'><input type='text' name='${this._objectName}[${this._modelName}s_attributes][${data.id}][caption]' value='' placeholder='${this._captionPlaceholder}'></span>`
      );
    }

    return container;
  }

  _listenToDeletePhoto() {
    this._delegated.container.on('click', '[data-delete]', (e, target) => {
      e.preventDefault();

      this._updateProcessing(1);
      let trigger = closest(target, '[data-delete]');
      let url = trigger.dataset.url;
      let labelConfirm = trigger.dataset.labelConfirm;
      if (!confirm(labelConfirm)) {
        return;
      }

      let photo = closest(trigger, '[data-photo-item], .preview').classList.add('deleting');

      xhr(url, { method: 'delete' }).then(() => {
        photo.parentNode.removeChild(photo);
        this._updateProcessing(-1);
        this._reorderSortableList();
      });
    });
  }

  _listenToEditPhoto() {
    this._delegated.container.on('click', '[data-edit]', (e, target) => {
      e.preventDefault();
      let trigger = closest(target, '[data-edit]');
      let url = trigger.dataset.url;
      Dialog.load(url);
    });
  }

  _updateLabel() {
    let text = '';
    switch (this._processing) {
      case 0:
        text = 'All files uploaded';
        break;

      case 1:
        text = 'Uploading photo...';
        break;

      default:
        text = `Uploading ${this._processing} photos...`;
        break;
    }
    this._ui.uploadLabelContainer.innerHTML = text;
  }

  _updateProcessing(delta) {
    this._processing = this._processing + delta;
  }

  _preventEarlySubmission() {
    this._ui.form.addEventListener('submit', e => {
      if (this._processing > 0) {
        alert('Please wait until all files are uploaded before submitting.');
        e.preventDefault();
        e.stopPropagation();
      }
    });
  }

  _reorderSortableList() {
    if (!this._isSortable) {
      return;
    }
    // this._collection.sortable('refresh');
    // @collection.sortable('refresh')
    // @collection.find('li').each (index, el)=>
    //   $(el).find('.photo-position-input').val(index)
  }
}

module.exports = ImageInput;
