var path = require('path');
var webpack = require('webpack');
var ChunkManifestPlugin = require('chunk-manifest-webpack-plugin');
var _ = require('lodash');

var config = module.exports = require('./main.config.js');

var WebpackMd5Hash = require(path.join(config.context, 'custom_node_modules', 'webpack_md5_hash'));

config.output = _.merge(config.output, {
  path: path.join(config.context, 'public', 'assets'),
  filename: '[name]-bundle-[chunkhash].js',
  chunkFilename: '[id]-bundle-[chunkhash].js',
});

config.plugins.push(
  new webpack.optimize.CommonsChunkPlugin('common', 'common-[chunkhash].js'),
  new ChunkManifestPlugin({
    filename: 'webpack-common-manifest.json',
    manifestVariable: 'webpackBundleManifest',
  }),
  new webpack.NamedModulesPlugin(),
  new WebpackMd5Hash()
);
