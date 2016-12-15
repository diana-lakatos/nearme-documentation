var els = $('.project-form-controller');
if (els.length > 0) {
  require.ensure('../sections/project_form', function(require){
    var ProjectForm = require('../sections/project_form');
    return new ProjectForm(els);
  });
}
