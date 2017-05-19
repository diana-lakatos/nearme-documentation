var PhotoView;

PhotoView = function() {
  function PhotoView() {
    this.inputTemplate = $('#photo-item-input-template');
  }

  PhotoView.prototype.create = function() {
    this.photo = $('<div class="photo-item"></div>');
    this.photo.html(
      '<div class="thumbnail-processing"><div class="loading-icon"></div><div class="loading-text">Processing...</div></div>'
    );
    return this.photo;
  };

  PhotoView.prototype.update = function(data) {
    this.data = this.normalizeData(data);
    return this;
  };

  PhotoView.prototype.resize = function() {
    var max_height, row_number;
    row_number = this.photo.closest('.uploaded').data('row');
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
        return $('.uploaded[data-row=' + row_number + ']').height(max_height + 'px');
      } else {
        return $('.uploaded[data-row=' + row_number + ']').height('auto');
      }
    }
  };

  PhotoView.prototype.singlePhotoHtml = function() {
    var cropLink, deleteLink;
    deleteLink = $(
      '<a data-url="' + this.data.destroy_url +
        '" class="badge delete-photo delete-photo-thumb photo-action">Delete</a>'
    );
    cropLink = $(
      '<a href="' + this.data.resize_url + '" rel="modal" data-id="photo-' + this.data.id +
        '" class="badge resize-photo photo-action">Rotate & Crop</a>'
    );
    this.photo.html(
      "<img src='" + this.data.url + "' width='" + this.data.thumbnail_dimensions.width +
        "' height='" +
        this.data.thumbnail_dimensions.height +
        "'>"
    );
    this.photo.append(deleteLink);
    return this.photo.append(cropLink);
  };

  PhotoView.prototype.multiplePhotoHtml = function(position) {
    var association_name_plural,
      association_name_singular,
      hidden,
      hidden_id,
      hidden_listing_id,
      hidden_position,
      input,
      listing_name_prefix,
      name_prefix;
    this.singlePhotoHtml();
    this.photo.append($('<span>').addClass('photo-position badge badge-inverse').text(position));
    input = $("<input type='text'>")
      .attr('name', this.inputTemplate.attr('name'))
      .attr('placeholder', this.inputTemplate.attr('placeholder'))
      .data('association-name', this.inputTemplate.data('association-name'));
    listing_name_prefix = input.attr('name');
    if (!input.data('association-name') || input.data('association-name').length === 0) {
      association_name_singular = 'photo';
    } else {
      association_name_singular = input.data('association-name');
    }
    association_name_plural = association_name_singular + 's';
    name_prefix = listing_name_prefix + ('[' + association_name_plural + '_attributes][') +
      this.data.id +
      ']';
    if (!this.inputTemplate.data('no-caption')) {
      input.attr('name', name_prefix + '[caption]');
      this.photo.append(input);
    }
    hidden = $('<input type="hidden">');
    hidden_position = hidden
      .clone()
      .attr('name', name_prefix + '[position]')
      .val(position)
      .addClass('photo-position-input');
    this.photo.attr('id', 'photo-' + this.data.id);
    this.photo.append(hidden_position);
    hidden_id = hidden.clone().attr('name', name_prefix + '[id]').val(this.data.id);
    this.photo.append(hidden_id);
    hidden_id = hidden
      .clone()
      .attr('name', listing_name_prefix + '[' + association_name_singular + '_ids][]')
      .val(this.data.id);
    this.photo.append(hidden_id);
    hidden_listing_id = hidden
      .clone()
      .attr('name', name_prefix + '[transactable_id]')
      .val(this.data.transactable_id);
    return this.photo.append(hidden_listing_id);
  };

  PhotoView.prototype.normalizeData = function(data) {
    var result;
    if (typeof data === 'object') {
      return data;
    } else {
      result = jQuery.parseJSON(data);
      if (!result) {
        result = jQuery.parseJSON($('pre', data).text());
      }
      return result;
    }
  };

  return PhotoView;
}();

module.exports = PhotoView;
