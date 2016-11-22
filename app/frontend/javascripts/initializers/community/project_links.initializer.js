var els = $('.project-links-listing');
if (els.length === 0) {
  require.ensure('../../community/project_links', function(require){
    var ProjectLinks = require('../../community/project_links');
    return new ProjectLinks(els);
  });
}
