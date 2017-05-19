var els = $('nav.panel-nav[data-internal-nav]');
if (els.length > 0) {
  require.ensure('../../dashboard/modules/panel_tabs', function(require) {
    var PanelTabs = require('../../dashboard/modules/panel_tabs');
    els.each(function() {
      return new PanelTabs(this);
    });
  });
}
