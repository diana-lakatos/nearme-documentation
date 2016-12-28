var
  webpack = require('webpack'),
  config = require('./manifest.config.js'),
  _ = require('lodash');

config = _.merge(config, {
  devtool: 'source-map'
});

config.plugins.push(
  new webpack.optimize.UglifyJsPlugin({
    mangle: {
      except: ['Modernizr','jQuery','$', 'exports', 'require']
    }
  })
);

module.exports = config;
