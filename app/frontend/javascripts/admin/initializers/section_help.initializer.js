let configDescription = document.querySelector('.config-section-description');
if (configDescription) {
  require.ensure('../sections/help', (require)=>{
    let Help = require('../sections/help');
    new Help(configDescription);
  });
}
