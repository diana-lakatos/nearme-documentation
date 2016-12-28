let els = document.querySelectorAll('[data-versions-modal]');

Array.prototype.forEach.call(els, (el)=>{
  el.addEventListener('click', (e)=>{
    e.preventDefault();
    require.ensure('../../admin/sections/versions_editor', (require)=>{
      const VersionsEditor = require('../../admin/sections/versions_editor');
      const versionsUrl = e.target.dataset.apiEndpoint;
      const editorTextarea = document.querySelector(e.target.dataset.editorSelector);
      return new VersionsEditor(versionsUrl, editorTextarea);
    });
  });
});
