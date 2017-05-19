function run(context = 'body') {
  var els = $(context).find('[data-image-input]');
  if (els.length > 0) {
    require.ensure('../../dashboard/modules/image_input', function(require) {
      var ImageInput = require('../../dashboard/modules/image_input');
      els.each(function() {
        return new ImageInput(this);
      });
    });
  }
}

let cocoonWrapper = $('.customizations');

cocoonWrapper.on('cocoon:after-insert', () => {
  run(cocoonWrapper);
});

run();
