var SupportAssigner;

SupportAssigner = function() {
  function SupportAssigner(container) {
    this.container = container;
    $(this.container).on('change', function() {
      var url, val;
      url = window.location.href;
      val = $(this).val();
      $('legend.status').html('saving...');
      $('.support select').prop('disabled', 'disabled');
      return $.ajax({
        data: { assigned_to_id: val },
        url: url,
        type: 'PUT',
        success: function() {
          $('legend.status').html('saved');
          $('.support select').prop('disabled', false);
          return setTimeout(
            function() {
              return $('legend.status').html('');
            },
            5000
          );
        }
      });
    });
  }

  return SupportAssigner;
}();

module.exports = SupportAssigner;
