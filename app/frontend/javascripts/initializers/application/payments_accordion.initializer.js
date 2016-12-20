var accordion = document.querySelector('.checkout .accordion');

if (accordion !== null) {
  require.ensure('../../application/payments_accordion', function(require){
    require('../../application/payments_accordion')();
  });
}
