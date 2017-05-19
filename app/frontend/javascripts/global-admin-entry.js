'use strict';

require('expose?jQuery|expose?$!jquery');
require('jquery-ujs/src/rails');

import NM from 'nm';

require('../vendor/bootstrap');

NM.on('ready', () => {
  require([ 'initializers/global_admin/linechart.initializer' ]);
});
