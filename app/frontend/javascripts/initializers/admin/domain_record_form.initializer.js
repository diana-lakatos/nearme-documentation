const form = document.getElementById('domain-record-form');
if (form) {
  require.ensure('../../admin/sections/domain_record_form', (require)=>{
    const DomainRecordForm = require('../../admin/sections/domain_record_form');
    return new DomainRecordForm(form);
  });
}

