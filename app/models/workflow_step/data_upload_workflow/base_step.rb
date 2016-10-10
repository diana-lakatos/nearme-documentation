class WorkflowStep::DataUploadWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(data_upload_id)
    @data_upload = DataUpload.find_by_id(data_upload_id)
  end

  def workflow_type
    'data_upload'
  end

  def enquirer
    @data_upload.uploader
  end

  def lister
    @data_upload.uploader
  end

  # data_upload
  #   DataUpload object
  def data
    { data_upload: @data_upload }
  end

  def importable_id
    @data_upload.importable_id
  end

  def should_be_processed?
    @data_upload.present?
  end
end
