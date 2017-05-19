/* global I18n */
var Tags;

require('../vendor/jquery-tokeninput');

Tags = function() {
  function Tags() {
    this.tagList = $('input[data-tags]');
    if (this.tagList != null) {
      this.bindEvents();
    }
  }

  Tags.prototype.bindEvents = function() {
    this.initialize();
    this.adjustDropdownWidth();
    return this.preventEnterSubmissionWhileOnInput();
  };

  Tags.prototype.initialize = function() {
    var json, options, translations;
    translations = this.getTranslations();
    json = JSON.parse(this.tagList.attr('data-tags'));
    options = {
      excludeCurrent: true,
      preventDuplicates: true,
      allowFreeTagging: this.atInstanceAdmin(),
      prePopulate: json.prepopulate,
      tokenValue: 'name',
      hintText: translations.hint,
      noResultsText: this.atInstanceAdmin() && translations.no_results.instance_admin ||
        translations.no_results['default'],
      searchingText: translations.searching
    };
    return this.tagList.tokenInput(json.url, options);
  };

  Tags.prototype.adjustDropdownWidth = function() {
    var controls, dropdown;
    dropdown = $('.token-input-dropdown');
    controls = $('.token-input-list').parent();
    return dropdown.width(controls.width());
  };

  Tags.prototype.preventEnterSubmissionWhileOnInput = function() {
    return this.tagList.on('keypress', function(event) {
      if (event.keyCode === '13') {
        return event.preventDefault();
      }
    });
  };

  Tags.prototype.getTranslations = function() {
    return I18n.t.components.tag_list;
  };

  Tags.prototype.atInstanceAdmin = function() {
    return window.location.href.match(/instance_admin/);
  };

  return Tags;
}();

module.exports = Tags;
