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

  def data
    { data_upload: @data_upload }
  end

  def transactable_type_id
    @data_upload.transactable_type_id
  end

end
