# frozen_string_literal: true
class WorkflowStep::DataUploadWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(data_upload_id)
    @data_upload_id = data_upload_id
  end

  def workflow_type
    'data_upload'
  end

  def enquirer
    data_upload.uploader
  end

  def lister
    data_upload.uploader
  end

  # data_upload
  #   DataUpload object
  def data
    { data_upload: data_upload }
  end

  delegate :importable_id, to: :data_upload

  def should_be_processed?
    data_upload.present?
  end

  def workflow_triggered_by
    enquirer
  end

  private

  def data_upload
    @data_upload ||= DataUpload.find_by(id: @data_upload_id) || DataUpload.new
  end
end
