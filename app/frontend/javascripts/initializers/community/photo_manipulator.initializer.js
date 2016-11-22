$(document).on('init:photomanipulator.nearme', function(event, container, options){
  options = options || {};
  require.ensure('../../community/photo/manipulator', function(require){
    var PhotoManipulator = require('../../community/photo/manipulator');
    return new PhotoManipulator($(container), options);
  });
});
