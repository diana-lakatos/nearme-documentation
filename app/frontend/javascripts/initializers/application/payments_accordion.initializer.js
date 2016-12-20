var accordion = document.querySelector('.checkout .accordion');

if (accordion.length !== null) {
  require.ensure('../../application/payments_accordion', function(require){
    require('../../application/payments_accordion')();
  });
}
