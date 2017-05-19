var SearchableAdminResource;

SearchableAdminResource = {
  commonBindEvents: function() {
    this.container.find('#to, #from').datepicker();
    this.container.on('click', '#to, #from', function(e) {
      return e.stopPropagation();
    });
    this.container.find('.date-dropdown').on('click', 'li:not(.date-range)', function() {
      var dateValue, parentContainer, selected;
      parentContainer = $(this).closest('.filter');
      parentContainer.find('.date-dropdown').find('li.selected').removeClass('selected');
      $(this).addClass('selected');
      dateValue = $(this).find('a').data('date');
      selected = $(this).find('a').text();
      parentContainer.find('.dropdown-trigger .current').text(selected);
      parentContainer.find('.dropdown-trigger input[type="hidden"]').attr('value', dateValue);
      return $(this).parents('form').submit();
    });
    this.container.find('.filter-value-dropdown').on('click', 'li', function() {
      var filterValue;
      filterValue = $(this).find('a').data('value');
      $(this)
        .closest('.filter')
        .find('.dropdown-trigger input[type="hidden"]')
        .attr('value', filterValue);
      return $(this).parents('form').submit();
    });
    return this.container.find('.date-dropdown').on('click', '.apply-filter', function() {
      var endDate, parentContainer, startDate;
      parentContainer = $(this).closest('.filter');
      startDate = parentContainer.find('#from').val();
      endDate = parentContainer.find('#to').val();
      if (startDate && endDate) {
        parentContainer.find('input[type="hidden"]#date').val(startDate + '-' + endDate);
        return $(this).parents('form').submit();
      }
    });
  }
};

module.exports = SearchableAdminResource;
