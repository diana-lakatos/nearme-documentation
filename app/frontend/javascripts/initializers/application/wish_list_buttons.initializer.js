var loader = require('../../components/wish_list_buttons/wish_list_button_loader');
loader.load();

$(document).on('load:searchResults.nearme', function() {
  loader.load();
});

$(document).on('rendered-search:ias.nearme', function() {
  loader.load();
});
