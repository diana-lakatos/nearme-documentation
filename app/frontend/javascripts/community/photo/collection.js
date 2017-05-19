var PhotoCollection,
  PhotoView,
  ScreenLockLoader,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

ScreenLockLoader = require('../screen_lock_loader');

PhotoView = require('./view');

PhotoCollection = function() {
  function PhotoCollection(container) {
    this.singlePhotoExists = bind(this.singlePhotoExists, this);
    this.coverPhoto = bind(this.coverPhoto, this);
    this.multiplePhoto = bind(this.multiplePhoto, this);
    this.container = container;
    this.sortable = container.find('#sortable-photos');
    this.uploaded = container.find('.uploaded').eq(0);
    this.initial_length = this.sortable.find('.photo-item').length;
    this.position = 1;
    this.photos = [];
    this.loader = new ScreenLockLoader(function() {
      return $('.loading');
    });
    this.processingPhotos = 0;
    this.init();
  }

  PhotoCollection.prototype.init = function() {
    this.listenToDeletePhoto();
    this.listenToFormSubmit();
    if (this.multiplePhoto()) {
      this.initializeSortable();
      return this.reorderSortableList();
    }
  };

  PhotoCollection.prototype.add = function() {
    var photo;
    photo = new PhotoView();
    if (this.multiplePhoto()) {
      photo.create().appendTo(this.sortable);
    } else {
      if (this.singlePhotoExists()) {
        this.uploaded.find('.photo-item, .media-section').eq(0).replaceWith(photo.create());
      } else {
        photo.create().appendTo(this.uploaded);
      }
      photo.resize();
    }

    /*
     * return index of new element, since push returns current length, we subtract 1
     */
    return this.photos.push(photo) - 1;
  };

  PhotoCollection.prototype.update = function(photo_index, data) {
    var photo;
    photo = this.photos[photo_index].update(data);
    if (this.multiplePhoto()) {
      photo.multiplePhotoHtml(this.initial_length + this.position++);
      return this.reorderSortableList();
    } else if (this.coverPhoto()) {
      return photo.coverPhotoHtml();
    } else {
      photo.singlePhotoHtml();
      return photo.resize();
    }
  };

  PhotoCollection.prototype.initializeSortable = function() {
    return this.sortable.sortable({
      stop: function(_this) {
        return function() {
          return _this.reorderSortableList();
        };
      }(this),
      placeholder: 'photo-placeholder',
      cancel: 'input'
    });
  };

  PhotoCollection.prototype.multiplePhoto = function() {
    return this.sortable.length > 0;
  };

  PhotoCollection.prototype.coverPhoto = function() {
    if (this.container.data('role') === 'cover-photo') {
      return true;
    }
  };

  PhotoCollection.prototype.singlePhotoExists = function() {
    return this.uploaded.find('img').length > 0;
  };

  PhotoCollection.prototype.listenToDeletePhoto = function() {
    return this.uploaded.on(
      'click',
      '.delete-photo, [data-delete-photo]',
      function(_this) {
        return function(e) {
          var link, photo, url;
          _this.processingPhotos += 1;
          link = $(e.target).closest('[data-url]');
          url = link.attr('data-url');
          if (confirm('Are you sure you want to delete this Photo?')) {
            photo = link
              .closest('.photo-item')
              .html(
                '<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">Deleting...</div></div>'
              );
            $.post(url, { _method: 'delete' }, function() {
              var max_height, row_number;
              row_number = photo.closest('.uploaded').data('row');
              photo.remove();
              if (row_number) {
                max_height = Math.max.apply(
                  Math,
                  $('.uploaded[data-row=' + row_number + ']').map(function(i, item) {
                    var photo_item;
                    photo_item = $(item).find('.photo-item');
                    if (photo_item.height() > 0) {
                      return photo_item.height() + 30;
                    } else {
                      return 0;
                    }
                  })
                );
                if (max_height > 0) {
                  $('.uploaded[data-row=' + row_number + ']').height(max_height + 'px');
                } else {
                  $('.uploaded[data-row=' + row_number + ']').height('auto');
                }
              }
              _this.initial_photo = _this.initial_photo - 1;
              _this.processingPhotos -= 1;
              if (_this.processingPhotos === 0) {
                _this.loader.hide();
              }
              if (_this.multiplePhoto()) {
                return _this.reorderSortableList();
              }
            });
          }
          return false;
        };
      }(this)
    );
  };

  PhotoCollection.prototype.listenToFormSubmit = function() {
    return this.container.parents('form').on(
      'submit',
      function(_this) {
        return function() {
          if (_this.processingPhotos > 0) {
            _this.loader.show();
            return false;
          }
        };
      }(this)
    );
  };

  PhotoCollection.prototype.reorderSortableList = function() {
    var el, i, index, ref, results;
    i = 0;
    ref = this.sortable.sortable('toArray');
    results = [];
    for (index in ref) {
      el = ref[index];
      if (el !== '' && $('#' + el + '.photo-item').length > 0) {
        $('#' + el).find('.photo-position-input').val(i);
        $('#' + el).find('.photo-position').text(parseInt(i) + 1);
        results.push(i++);
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  return PhotoCollection;
}();

module.exports = PhotoCollection;
