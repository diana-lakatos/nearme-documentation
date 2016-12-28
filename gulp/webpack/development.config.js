var webpack = require('webpack');
var _ = require('lodash');
var config = require('./main.config.js');

config = _.merge(config, {
  debug: true,
  displayErrorDetails: true,
  outputPathinfo: true,
  devtool: 'source-map'
});

config.plugins.push(
  new webpack.optimize.CommonsChunkPlugin('common', 'common-bundle.js')
);

module.exports = config;
