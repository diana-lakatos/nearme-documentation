var InstanceAdminCustomAttributesController;

InstanceAdminCustomAttributesController = function() {
  function InstanceAdminCustomAttributesController(container) {
    this.container = container;
    this.htmlTag = this.container.find('#custom_attribute_html_tag');
    this.bindEvents();
  }

  InstanceAdminCustomAttributesController.prototype.bindEvents = function() {
    return this.htmlTag.on('change', function() {
      var section;
      $('.properties').removeClass('active');
      section = function() {
        switch (this.value) {
          case 'range':
            return '.range-properties';
        }
      }.call(this);
      return $(section).addClass('active');
    });
  };

  return InstanceAdminCustomAttributesController;
}();

module.exports = InstanceAdminCustomAttributesController;
