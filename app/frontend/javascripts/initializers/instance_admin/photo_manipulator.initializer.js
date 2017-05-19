$(document).on('init:photomanipulator.nearme', function(event, container, options) {
  options = options || {};
  require.ensure('../../components/photo/manipulator', function(require) {
    var PhotoManipulator = require('../../components/photo/manipulator');
    return new PhotoManipulator($(container), options);
  });
});
