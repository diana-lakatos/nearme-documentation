var webpack = require('webpack');
var config = require('./manifest.config.js');

config.plugins.push(
  new webpack.optimize.UglifyJsPlugin({
    compress: {
      warnings: false
    },
    mangle: {
      except: ['Modernizr', 'jQuery', '$', 'exports', 'require', '_']
    }
  })
);

module.exports = config;
