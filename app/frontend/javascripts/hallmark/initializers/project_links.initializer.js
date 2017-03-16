var els = $('.project-links-listing');
if (els.length > 0) {
  require.ensure('../project_links', function(require){
    var ProjectLinks = require('../project_links');
    return new ProjectLinks(els);
  });
}
