class CustomThemeAssetUploader < BaseUploader
  before :store, :prepare_for_uploading_new_file
  before :store, :new_file_uploaded

  def store_dir
    "#{instance_prefix}/custom_themes/#{model.custom_theme.id}/#{model.id}/#{model.file_updated_at.utc.to_formatted_s(:number)}"
  end

  def prepare_for_uploading_new_file(_file)
    model.try(:prepare_for_uploading_new_file)
  end

  def new_file_uploaded(_file)
    model.try(:new_file_uploaded)
  end
end
