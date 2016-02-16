var webpack = require('webpack');
var config = module.exports = require('./manifest.config.js');
var _ = require('lodash');

config = _.merge(config, {
  devtool: 'source-map'
});

config = _.merge(config, {
  devtool: 'source-map'
});

config.plugins.push(
  new webpack.optimize.UglifyJsPlugin()
);
