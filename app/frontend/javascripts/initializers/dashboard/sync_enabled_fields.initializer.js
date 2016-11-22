var els = $('[data-listing-enabled]');
if (els.length > 0) {
  require.ensure('../../dashboard/listings/sync_enabled_fields', function(require){
    var SyncEnabledFields = require('../../dashboard/listings/sync_enabled_fields');
    return new SyncEnabledFields(els);
  });
}
