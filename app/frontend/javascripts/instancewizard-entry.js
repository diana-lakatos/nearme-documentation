'use strict';

import NM from 'nm';

require('expose?jQuery|expose?$!jquery');
require('jquery-ujs/src/rails');
require('../vendor/bootstrap');
require('../vendor/bootstrap-modal-fullscreen');

NM.on('ready', ()=>{
  require('initializers/instance_wizard/instance_wizard_form.initializer');
});
