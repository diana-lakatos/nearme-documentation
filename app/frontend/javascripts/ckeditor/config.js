// PS: Everytime you change this file, you need to restart the server.
window.CKEDITOR.editorConfig = function(config) {
  config.toolbar_simple = [
    [ 'Cut', 'Copy', 'Paste' ],
    [ 'Undo', 'Redo' ],
    [ 'Bold', 'Italic', 'Underline', 'Strike' ],
    [ 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', 'Blockquote' ],
    [ 'Link', 'Unlink' ],
    [ 'Image', 'Iframe' ]
  ];

  config.filebrowserBrowseUrl = '/ckeditor/attachment_files';
  config.filebrowserFlashBrowseUrl = '/ckeditor/attachment_files';
  config.filebrowserFlashUploadUrl = '/ckeditor/attachment_files';
  config.filebrowserImageBrowseLinkUrl = '/ckeditor/pictures';
  config.filebrowserImageBrowseUrl = '/ckeditor/pictures';
  config.filebrowserImageUploadUrl = '/ckeditor/pictures';
  config.filebrowserUploadUrl = '/ckeditor/attachment_files';

  config.filebrowserParams = function() {
    var csrf_token,
      csrf_param,
      meta,
      metas = document.getElementsByTagName('meta'),
      params = new Object();

    for (var i = 0; i < metas.length; i++) {
      meta = metas[i];

      switch (meta.name) {
        case 'csrf-token':
          csrf_token = meta.content;
          break;

        case 'csrf-param':
          csrf_param = meta.content;
          break;

        default:
          continue;
      }
    }

    if (csrf_param !== undefined && csrf_token !== undefined) {
      params[csrf_param] = csrf_token;
    }

    return params;
  };

  config.addQueryString = function(url, params) {
    var queryString = [];

    if (!params) {
      return url;
    } else {
      for (var i in params)
        queryString.push(i + '=' + encodeURIComponent(params[i]));
    }

    return url + (url.indexOf('?') != -1 ? '&' : '?') + queryString.join('&');
  };

  window.CKEDITOR.on('dialogDefinition', function(ev) {
    var dialogName = ev.data.name;
    var dialogDefinition = ev.data.definition;
    var content, upload;

    if (
      window.CKEDITOR.tools.indexOf([ 'link', 'image', 'attachment', 'flash' ], dialogName) > -1
    ) {
      content = dialogDefinition.getContents('Upload') || dialogDefinition.getContents('upload');
      upload = content == null ? null : content.get('upload');

      if (upload && upload.filebrowser && upload.filebrowser['params'] === undefined) {
        upload.filebrowser['params'] = config.filebrowserParams();
        upload.action = config.addQueryString(upload.action, upload.filebrowser['params']);
      }
    }
  });

  config.extraPlugins = 'iframe';
};
