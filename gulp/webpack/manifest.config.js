var path = require('path');
var webpack = require('webpack');
var ChunkManifestPlugin = require('chunk-manifest-webpack-plugin');
var _ = require('lodash');

var config = require('./main.config.js');

config.output = _.merge(config.output, {
  path: path.join(config.appFolder, 'tmp', 'assets'),
  chunkFilename: '[id]-bundle.js'
});

config.plugins.push(
  new webpack.optimize.CommonsChunkPlugin('common', 'common.js'),
  new ChunkManifestPlugin({
    filename: 'webpack-common-manifest.json',
    manifestVariable: 'webpackBundleManifest'
  })
);

module.exports = config;
