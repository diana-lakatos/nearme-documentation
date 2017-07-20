# frozen_string_literal: true
class FaviconController < ApplicationController
  skip_before_action :redirect_unverified_user
  skip_before_action :redirect_if_marketplace_password_protected
  def show
    custom_icon = PlatformContext.current.theme.favicon_image

    if custom_icon.present?
      if File.exist?(custom_icon.path)
        # Works for local
        send_file custom_icon.path, filename: 'favicon.ico', type: custom_icon.file.content_type, disposition: 'inline'
      else
        # http://stackoverflow.com/questions/12277971/using-send-file-to-download-a-file-from-amazon-s3
        custom_icon_data = open(custom_icon.url)
        send_data custom_icon_data.read, filename: 'favicon.ico', type: custom_icon.file.content_type,
                                         disposition: 'inline'
      end
    else
      send_file "#{Rails.root}/public/default_favicon.ico", filename: 'favicon.ico', type: 'image/png',
                                                            disposition: 'inline'
    end
  end
end
