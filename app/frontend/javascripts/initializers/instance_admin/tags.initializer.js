if ($('input[data-tags]').length > 0) {
  require.ensure('../../components/tags', function(require) {
    var Tags = require('../../components/tags');
    return new Tags();
  });
}
