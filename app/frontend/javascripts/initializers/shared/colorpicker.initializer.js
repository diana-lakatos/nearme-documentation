if (document.querySelector('input[type="color"]')) {
  require.ensure('spectrum-colorpicker', function(require){
    require('spectrum-colorpicker');
  });
}
