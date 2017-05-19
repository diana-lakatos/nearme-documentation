var InstanceAdminProjectsController;

InstanceAdminProjectsController = function() {
  function InstanceAdminProjectsController(container) {
    this.container = container;
    this.container.find('a[data-download-report]').on('click', function(e) {
      var formParameters, reportUrl;
      formParameters = $(this).closest('form').serialize();
      reportUrl = $(this).data('report-url');
      location.href = reportUrl + '?' + formParameters;
      return e.preventDefault();
    });
  }

  return InstanceAdminProjectsController;
}();

module.exports = InstanceAdminProjectsController;
