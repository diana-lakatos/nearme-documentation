# frozen_string_literal: true
class MarketplaceReportUploader < PrivateFileUploader
  def extension_white_list
    %w(zip csv)
  end
end
