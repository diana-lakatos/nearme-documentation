const form = document.getElementById('domain-record-form');
if (form) {
  require.ensure('../sections/domain_record_form', require => {
    const DomainRecordForm = require('../sections/domain_record_form');
    return new DomainRecordForm(form);
  });
}
