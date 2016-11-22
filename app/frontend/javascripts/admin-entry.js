'use strict';

import NM from 'nm';

require('../vendor/bootstrap');

NM.on('ready', ()=>{
  require('initializers/shared/linechart.initializer');
});
