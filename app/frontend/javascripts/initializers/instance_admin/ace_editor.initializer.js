var els = $('textarea[data-editor]');
if (els.length > 0) {
  require.ensure('../../components/ace_editor_textarea_binding', function(require){
    var bindEditor = require('../../components/ace_editor_textarea_binding');
    els.each(function(){
      bindEditor(this);
    });
  });
}

