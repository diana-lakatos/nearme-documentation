var
  webpack = require('webpack'),
  config = require('./manifest.config.js');

config.plugins.push(
  new webpack.optimize.UglifyJsPlugin({
    mangle: {
      except: ['Modernizr','jQuery','$', 'exports', 'require']
    }
  })
);

module.exports = config;
