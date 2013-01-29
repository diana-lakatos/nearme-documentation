define(['handlebars'], function ( Handlebars ) {
  function shorten ( text ) {
    return (text.length > 10)? text.substr(0,7) + "..." : text;
  }
  Handlebars.registerHelper( 'shorten', shorten );
  return shorten;
});
