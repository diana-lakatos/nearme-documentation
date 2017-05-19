var DashboardDataUploadController;

DashboardDataUploadController = function() {
  function DashboardDataUploadController(container, statusUrl, dataUploads) {
    this.container = container;
    this.statusUrl = statusUrl;
    this.dataUploads = dataUploads;
    this.monitor();
  }

  DashboardDataUploadController.prototype.monitor = function() {
    var dataUploadsIds, key;
    dataUploadsIds = function() {
      var results;
      results = [];
      for (key in this.dataUploads) {
        results.push(key);
      }
      return results;
    }.call(this);
    if (dataUploadsIds.length > 0) {
      return $.get(this.statusUrl, { 'ids[]': dataUploadsIds }).done(
        function(_this) {
          return function(data) {
            var data_upload, i, len;
            for (i = 0, len = data.length; i < len; i++) {
              data_upload = data[i];
              _this.refreshDataUpload(data_upload);
            }
            return setTimeout(
              function() {
                return _this.monitor();
              },
              3000
            );
          };
        }(this)
      );
    }
  };

  DashboardDataUploadController.prototype.refreshDataUpload = function(data_upload) {
    var id, progress, state;
    id = data_upload[0];
    state = data_upload[1];
    progress = data_upload[2];
    if (state !== this.dataUploads[id].state) {
      this.dataUploads[id].state = state;
      this.updateDataUploadRow(id);
      if (state !== 'importing' && state !== 'processing') {
        return delete this.dataUploads[id];
      }
    } else if (state === 'importing') {
      return this.updateDataUploadProgress(id, progress);
    }
  };

  DashboardDataUploadController.prototype.updateDataUploadRow = function(id) {
    return $.get(this.dataUploads[id].url).done(
      function(_this) {
        return function(data) {
          var dataUploadRow;
          dataUploadRow = _this.domForDataUploadId(id);
          dataUploadRow.replaceWith(data);
          return _this.domForDataUploadId(id).effect('highlight', {}, 3000);
        };
      }(this)
    );
  };

  DashboardDataUploadController.prototype.updateDataUploadProgress = function(id, progress) {
    return this.progressBarDivForDataUploadId(id).css({ width: progress + '%' });
  };

  DashboardDataUploadController.prototype.domForDataUploadId = function(id) {
    return $('[data-data-upload-row=' + id + ']');
  };

  DashboardDataUploadController.prototype.progressBarDivForDataUploadId = function(id) {
    return this.domForDataUploadId(id).find('[data-status-column] .bar');
  };

  return DashboardDataUploadController;
}();

module.exports = DashboardDataUploadController;
