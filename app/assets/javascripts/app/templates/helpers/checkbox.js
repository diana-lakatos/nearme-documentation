define(['handlebars'], function ( Handlebars ) {
  function checkbox ( value, options ) {
    var $el = $('<div />').html( options.fn(this) );
    $el.find('[value=' + value + ']').attr({'checked':'checked'});
    return $el.html();
  }
  Handlebars.registerHelper( 'checkbox', checkbox );
  return checkbox;
});
