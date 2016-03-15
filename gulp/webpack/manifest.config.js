var path = require('path');
var webpack = require('webpack');
var ChunkManifestPlugin = require('chunk-manifest-webpack-plugin');
var _ = require('lodash');

var config = module.exports = require('./main.config.js');

config.output = _.merge(config.output, {
  path: path.join(config.context, 'tmp', 'assets'),
  chunkFilename: '[id]-bundle.js'
});

config.plugins.push(
  new webpack.optimize.CommonsChunkPlugin('common', 'common.js'),
  new ChunkManifestPlugin({
    filename: 'webpack-common-manifest.json',
    manifestVariable: 'webpackBundleManifest',
  })
);
