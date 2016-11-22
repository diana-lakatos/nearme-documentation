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

  require('initializers/community/activity_feed.initializer');
  require('initializers/community/fileupload.initializer');
  require('initializers/community/flash_message.initializer');
  require('initializers/community/general.initializer');
  require('initializers/community/group_form.initializer');
  require('initializers/community/intro_video.initializer');
  require('initializers/community/modal.initializer');
  require('initializers/community/photo_manipulator.initializer');
  require('initializers/community/project_form.initializer');
  require('initializers/community/project_links.initializer');
  require('initializers/community/search.initializer');
  require('initializers/community/see_more.initializer');
  require('initializers/community/tabs.initializer');
  require('initializers/community/tutorial.initializer');
});
