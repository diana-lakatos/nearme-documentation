var $container = $('.group-a');

if ($container.length > 0) {
  var $tabList = $('ul.nav.nav-tabs li'), tabId, index;

  $('[data-force-toggle-tab]').on('click', function(event) {
    event.preventDefault();
    tabId = $(this).data('force-toggle-tab');
    index = $tabList.find('a').index($('[href="' + tabId + '"]'));

    $tabList.removeClass('active').eq(index).addClass('active');
    $(this).tab('show');
  });
}

