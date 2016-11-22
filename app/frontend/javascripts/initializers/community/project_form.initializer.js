var els = $('.project-form-controller');
if (els.length > 0) {
  require.ensure('../../community/sections/project_form', function(require){
    var ProjectForm = require('../../community/sections/project_form');
    return new ProjectForm(els);
  });
}
