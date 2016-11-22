var els = $('[data-document-requirements], .document-requirements-container');
if (els.length > 0) {
  require.ensure('../../dashboard/controllers/document_requirements_controller', function(require){
    var DocumentRequirementsController = require('../../dashboard/controllers/document_requirements_controller');
    els.each(function(){
      return new DocumentRequirementsController(this);
    });
  });
}
