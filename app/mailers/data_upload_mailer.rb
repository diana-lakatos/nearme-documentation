class DataUploadMailer < InstanceMailer
  layout 'mailer'

  def notify_uploader_of_failed_import(data_upload)
    @data_upload = data_upload

    mail to: @data_upload.uploader.email,
         subject_locals: { data_upload: @data_upload }
  end

  def notify_uploader_of_finished_import(data_upload)
    @data_upload = data_upload

    mail to: @data_upload.uploader.email,
         subject_locals: { data_upload: @data_upload }
  end
end
