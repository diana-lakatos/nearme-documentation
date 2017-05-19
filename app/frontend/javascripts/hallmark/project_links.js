var ProjectLinks;

ProjectLinks = function() {
  function ProjectLinks(el) {
    this.wrapper = $(el);
    this.initEvents();
  }

  ProjectLinks.prototype.initEvents = function() {
    var error_block, i, len, ref, results;
    this.wrapper.on(
      'click',
      '[data-link-edit]',
      function(_this) {
        return function(e) {
          return _this.enableEditForm($(e.target).closest('.link'));
        };
      }(this)
    );
    this.wrapper.on(
      'click',
      '[data-link-remove]',
      function(_this) {
        return function(e) {
          return _this.hideOnRemove($(e.target).closest('.link'));
        };
      }(this)
    );
    this.wrapper.on(
      'change',
      'input[type=file]',
      function(_this) {
        return function(e) {
          return _this.updateUploadLabel($(e.target).closest('.control-group'));
        };
      }(this)
    );
    ref = this.wrapper.find('[data-link-wrapper] .error-block');
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      error_block = ref[i];
      results.push($(error_block).closest('[data-link-wrapper]').find('[data-link-edit]').click());
    }
    return results;
  };

  ProjectLinks.prototype.enableEditForm = function(link) {
    link.find('.media-group_link-form').show();
    return link.find('[data-link-edit]').hide();
  };

  ProjectLinks.prototype.hideOnRemove = function(link) {
    return link.fadeOut();
  };

  ProjectLinks.prototype.trimFileName = function(str) {
    return str.replace('C:\\fakepath\\', '');
  };

  ProjectLinks.prototype.updateUploadLabel = function(control_group) {
    var file_name;
    file_name = this.trimFileName(control_group.find('[type="file"]').val());
    return control_group.find('label').html(file_name);
  };

  return ProjectLinks;
}();

module.exports = ProjectLinks;
