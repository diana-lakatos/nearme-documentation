var els = $('.prices-container');
if (els.length > 0) {
  require.ensure('../../dashboard/listings/price_fields', function(require){
    var PriceFields = require('../../dashboard/listings/price_fields');
    els.each(function(){
      return new PriceFields(this);
    });
  });
}
