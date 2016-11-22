var els = $('[data-transactable-collaborator]');
if (els.length > 0) {
  require.ensure('../../dashboard/listings/collaborators', function(require){
    var Collaborators = require('../../dashboard/listings/collaborators');
    return new Collaborators($(els[0]).closest('form'));
  });
}
