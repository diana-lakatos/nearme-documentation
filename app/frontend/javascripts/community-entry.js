'use strict';

import NM from 'nm';

require('expose?jQuery|expose?$!jquery');
require('jquery-ujs/src/rails');

require('community/vendor/css_browser_selector.min');
require('community/vendor/placeholders.min');
require('community/vendor/foreach.polyfill');
require('community/vendor/hrefid.jquery');
require('community/vendor/selectize.mod');
require('community/vendor/trueresize');
require('community/vendor/geocomplete');
require('community/vendor/bootstrap-tab');
require('community/vendor/jquery-ui');
require('vendor/jQueryRotate');
require('../vendor/cocoon');


NM.on('ready', ()=>{
  require('initializers/shared/ckeditor.initializer');

  require('community/initializers/activity_feed.initializer');
  require('community/initializers/fileupload.initializer');
  require('community/initializers/flash_message.initializer');
  require('community/initializers/general.initializer');
  require('community/initializers/group_form.initializer');
  require('community/initializers/intro_video.initializer');
  require('community/initializers/modal.initializer');
  require('community/initializers/photo_manipulator.initializer');
  require('community/initializers/project_form.initializer');
  require('community/initializers/project_links.initializer');
  require('community/initializers/search.initializer');
  require('community/initializers/see_more.initializer');
  require('community/initializers/tabs.initializer');
  require('community/initializers/tutorial.initializer');
});
