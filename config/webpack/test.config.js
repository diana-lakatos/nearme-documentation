var webpack = require('webpack');
var ChunkManifestPlugin = require('chunk-manifest-webpack-plugin');
var WebpackMd5Hash = require('webpack-md5-hash');
var _ = require('lodash');
var path = require('path');

var config = module.exports = require('./main.config.js');

config.output = _.merge(config.output, {
  path: path.join(config.context, 'public', 'assets'),
  filename: '[name]-bundle-[chunkhash].js',
  chunkFilename: '[id]-bundle-[chunkhash].js',
});

config.plugins.push(
  new webpack.optimize.CommonsChunkPlugin('common', 'common-[chunkhash].js'),
  new webpack.NamedModulesPlugin(),
  new ChunkManifestPlugin({
    filename: 'webpack-common-manifest.json',
    manifestVariable: 'webpackBundleManifest',
  }),
  new WebpackMd5Hash()
);
