var SearchableAdminService;

SearchableAdminService = {
  serviceBindEvents: function() {
    this.container.find('.item-type-dropdown').on('click', 'li', function() {
      var itemTypeValue, parentContainer, selected;
      parentContainer = $(this).closest('.filter');
      parentContainer.find('li.selected').removeClass('selected');
      $(this).addClass('selected');
      itemTypeValue = $(this).find('a').data('item-type-id');
      selected = $(this).find('a').text();
      parentContainer.find('.dropdown-trigger .current').text(selected);
      parentContainer.find('.dropdown-trigger input[type="hidden"]').attr('value', itemTypeValue);
      return $(this).parents('form').submit();
    });
    return this.container.find('a[data-download-report]').on('click', function(e) {
      var formParameters, reportUrl;
      formParameters = $(this).closest('form').serialize();
      reportUrl = $(this).data('report-url');
      location.href = reportUrl + '?' + formParameters;
      return e.preventDefault();
    });
  }
};

module.exports = SearchableAdminService;
