$(document).on('init:photomanipulator.nearme', function(event, el){
  require.ensure('../../dashboard/modules/photo_manipulator', function(require){
    var PhotoManipulator = require('../../dashboard/modules/photo_manipulator');
    new PhotoManipulator(el);
  });
});
