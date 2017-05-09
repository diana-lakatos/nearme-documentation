'use strict';

import NM from 'nm';

require('expose?jQuery|expose?$!jquery');
require('jquery-ujs/src/rails');

require('hallmark/vendor/css_browser_selector.min');
require('hallmark/vendor/selectize.mod');
require('hallmark/vendor/trueresize');
require('hallmark/vendor/geocomplete');
require('hallmark/vendor/bootstrap-tab');
require('hallmark/vendor/jquery-ui');
require('vendor/jQueryRotate');
require('../vendor/cocoon');

NM.on('ready', () => {
  require('initializers/shared/ckeditor.initializer');
  require('initializers/shared/notification_preferences_form');

  require('hallmark/initializers/fileupload.initializer');
  require('hallmark/initializers/flash_message.initializer');
  require('hallmark/initializers/general.initializer');
  require('hallmark/initializers/group_form.initializer');
  require('hallmark/initializers/modal.initializer');
  require('hallmark/initializers/photo_manipulator.initializer');
  require('hallmark/initializers/project_form.initializer');
  require('hallmark/initializers/project_links.initializer');
  require('hallmark/initializers/search.initializer');
  require('hallmark/initializers/paginable_container.initializer');
  require('hallmark/initializers/tabs.initializer');
  require('hallmark/initializers/tutorial.initializer');
  require('hallmark/initializers/gallery.initializer');
  require('hallmark/initializers/user_entries.initializer');
  require('hallmark/initializers/phone_numbers.initializer');
  require('hallmark/initializers/follow_buttons.initializer');
  require('hallmark/initializers/user_messages.initializer');
});
