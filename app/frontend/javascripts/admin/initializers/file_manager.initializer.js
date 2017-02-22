const el = document.getElementById('file-manager');

if (el) {
  require.ensure('../file_manager/file_manager', (require)=>{
    const FileManager = require('../file_manager/file_manager');
    return new FileManager(el);
  });
}
