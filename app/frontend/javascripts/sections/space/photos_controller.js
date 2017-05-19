var SpacePhotosController;

SpacePhotosController = function() {
  function SpacePhotosController(container) {
    this.container = container;
    this.photo = this.container.find('.photo');
    this.caption = this.container.find('.caption');
    this.listContainer = this.container.find('.photos-list');
    this.listPrev = this.listContainer.find('.prev');
    this.listNext = this.listContainer.find('.next');
    this.listWrapper = this.listContainer.find('.photos-wrapper');
    this.list = this.listContainer.find('ul');
    this.bindEvents();
    this.showPhoto(this.list.find('li').eq(0));
  }

  SpacePhotosController.prototype.bindEvents = function() {
    this.list.on(
      'click',
      'li',
      function(_this) {
        return function(event) {
          return _this.showPhoto($(event.target).closest('li'));
        };
      }(this)
    );
    this.listPrev.on(
      'click',
      function(_this) {
        return function() {
          return _this.prev();
        };
      }(this)
    );
    return this.listNext.on(
      'click',
      function(_this) {
        return function() {
          return _this.next();
        };
      }(this)
    );
  };

  SpacePhotosController.prototype.prev = function() {
    var prev;
    prev = this.list.find('li.selected').prev();
    if (prev.length > 0) {
      return this.showPhoto(prev);
    }
  };

  SpacePhotosController.prototype.next = function() {
    var next;
    next = this.list.find('li.selected').next();
    if (next.length > 0) {
      return this.showPhoto(next);
    }
  };

  SpacePhotosController.prototype.hasNext = function() {
    return this.list.find('li.selected').next().length > 0;
  };

  SpacePhotosController.prototype.hasPrev = function() {
    return this.list.find('li.selected').prev().length > 0;
  };

  SpacePhotosController.prototype.updatePrevNext = function() {
    if (this.hasNext()) {
      this.listNext.css('visibility', 'visible');
    } else {
      this.listNext.css('visibility', 'hidden');
    }
    if (this.hasPrev()) {
      return this.listPrev.css('visibility', 'visible');
    } else {
      return this.listPrev.css('visibility', 'hidden');
    }
  };

  SpacePhotosController.prototype.centerListView = function() {
    var count, index, offset, offsetPos, photos, selected;
    photos = this.list.find('li');
    selected = photos.filter('.selected').eq(0);
    count = photos.length;
    index = photos.index(selected);
    offsetPos = index <= 1 ? 0 : index < count - 1 ? index - 1 : index - 2;
    offset = offsetPos * selected.outerHeight(true);
    return this.list.animate({ 'margin-top': '-' + offset + 'px' }, 'fast');
  };

  SpacePhotosController.prototype.showPhoto = function(listItem) {
    this.photo.css({ backgroundImage: "url('" + listItem.find('img').attr('data-url') + "')" });
    this.caption.text(listItem.find('img').attr('alt'));
    listItem.siblings().removeClass('selected');
    listItem.addClass('selected');
    this.centerListView();
    return this.updatePrevNext();
  };

  return SpacePhotosController;
}();

module.exports = SpacePhotosController;
