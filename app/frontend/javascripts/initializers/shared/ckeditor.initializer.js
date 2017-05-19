if (document.querySelector('div.ckeditor')) {
  require.ensure(
    '../../ckeditor/init',
    function(require) {
      require('../../ckeditor/init');
    },
    'ckeditor'
  );
}
