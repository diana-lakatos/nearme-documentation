if Rails.env.production?
  Dropbox::API::Config.mode       = "dropbox"
else
  Dropbox::API::Config.mode       = "sandbox"
  Dropbox::API::Config.app_key    = "bgce8czxteo40fp"
  Dropbox::API::Config.app_secret = "bvg25p3f623vvi2"
end
DROPBOX = DropboxWrapper.new
