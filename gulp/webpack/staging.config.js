var
  config = require('./manifest.config.js'),
  _ = require('lodash');

config = _.merge(config, {
  devtool: 'source-map'
});

module.exports = config;
