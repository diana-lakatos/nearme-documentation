var webpack = require('webpack');
var config = module.exports = require('./manifest.config.js');

config.plugins.push(
  new webpack.optimize.UglifyJsPlugin()
);
