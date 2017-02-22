document.addEventListener('initialize:property_form.nearme', ()=>{
  require.ensure('../sections/properties_form', (require)=>{
    let PropertyForm = require('../sections/properties_form');
    return new PropertyForm(document.getElementById('property-form'));
  });
});
