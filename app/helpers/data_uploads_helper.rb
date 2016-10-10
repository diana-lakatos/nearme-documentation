module DataUploadsHelper
  def data_upload_full_log_summary(data_upload)
    data_upload_sanitize_encountered_error(data_upload.encountered_error) + "\n" + data_upload.parsing_result_log.to_s
  end

  def data_upload_sanitize_encountered_error(encountered_error)
    encountered_error = encountered_error.to_s
    parts = encountered_error.split(/\n/)
    if parts.length > 1
      parts[0]
    else
      encountered_error
    end
  end
end
