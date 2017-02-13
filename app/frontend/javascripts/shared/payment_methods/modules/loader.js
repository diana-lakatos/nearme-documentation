module.exports = {
  show: () => {
    console.info('PaymentMethods Loader :: SHOW Spinner');
    $('.spinner-overlay').show();
  },
  hide: () => {
    console.info('PaymentMethods Loader :: HIDE Spinner');
    $('.spinner-overlay').hide();
  }
};
