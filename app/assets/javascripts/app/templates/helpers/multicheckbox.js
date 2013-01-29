define(['handlebars'], function ( Handlebars ) {
  function multicheckbox ( values, options ) {
    var $el = $('<div />').html( options.fn(this) );
    _.each(values, function(value){
      $el.find('[value=' + value + ']').attr({'checked':'checked'});
    });
    return $el.html();
  }
  Handlebars.registerHelper( 'multicheckbox', multicheckbox );
  return multicheckbox;
});
