var els = $('[data-booking-type-list]');
if (els.length > 0) {
  require.ensure('../../instance_admin/forms/panel_tabs', function(require){
    var PanelTabs = require('../../instance_admin/forms/panel_tabs');
    els.each(function(){
      return new PanelTabs(this);
    });
  });
}
