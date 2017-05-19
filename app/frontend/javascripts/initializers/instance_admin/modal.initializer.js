var Modal = require('../../components/modal');
Modal.listen();

$(document).on('close:modal.nearme', function() {
  Modal.close();
});

$(document).on('load:modal.nearme', function(event, url) {
  Modal.load(url);
});

$(document).on('setclass:modal.nearme', function(event, klass) {
  Modal.setClass(klass);
});
