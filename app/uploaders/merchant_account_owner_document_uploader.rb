class MerchantAccountOwnerDocumentUploader < PrivateFileUploader
  include CarrierWave::ImageDefaults

  def extension_white_list
    %w(jpg jpeg png)
  end
end
