var config = module.exports = require('./manifest.config.js');
var _ = require('lodash');

config = _.merge(config, {
  devtool: 'source-map'
});

