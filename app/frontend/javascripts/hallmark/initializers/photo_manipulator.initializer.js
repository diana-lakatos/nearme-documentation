$(document).on('init:photomanipulator.nearme', function(event, container, options) {
  options = options || {};
  require.ensure('../photo/manipulator', function(require) {
    var PhotoManipulator = require('../photo/manipulator');
    return new PhotoManipulator($(container), options);
  });
});
