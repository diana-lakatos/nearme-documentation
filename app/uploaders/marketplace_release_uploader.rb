class MarketplaceReleaseUploader < PrivateFileUploader
  def extension_white_list
    %w(zip)
  end
end
