const el = document.getElementById('file-manager');

if (el) {
  require.ensure('../../admin/file_manager/file_manager', (require)=>{
    const FileManager = require('../../admin/file_manager/file_manager');
    return new FileManager(el);
  });
}
