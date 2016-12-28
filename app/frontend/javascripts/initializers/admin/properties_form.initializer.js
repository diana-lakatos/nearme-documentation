document.addEventListener('initialize:property_form.nearme', ()=>{
  require.ensure('../../admin/sections/properties_form', (require)=>{
    let PropertyForm = require('../../admin/sections/properties_form');
    return new PropertyForm(document.getElementById('property-form'));
  });
});
