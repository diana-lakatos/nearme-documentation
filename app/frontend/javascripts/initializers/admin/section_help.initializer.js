let configDescription = document.querySelector('.config-section-description');
if (configDescription) {
  require.ensure('../../admin/sections/help', (require)=>{
    let Help = require('../../admin/sections/help');
    new Help(configDescription);
  });
}
