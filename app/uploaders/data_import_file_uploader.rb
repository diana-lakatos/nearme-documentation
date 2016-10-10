class DataImportFileUploader < PrivateFileUploader
  def extension_white_list
    %w(csv xml)
  end
end
