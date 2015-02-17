AssetSync.configure do |config|
  config.fog_provider = 'AWS'
  config.aws_access_key_id = 'AKIAJC37Z6XCOCR245YA'
  config.aws_secret_access_key = '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'
  # To use AWS reduced redundancy storage.
  # config.aws_reduced_redundancy = true
  if ENV['FOG_DIR']
    config.fog_directory = ENV['FOG_DIR']
  else
    case ENV['BRANCH_NAME']
    when 'production'
      config.fog_directory = 'near-me-assets'
    else
      config.fog_directory = 'near-me-assets-staging'
    end
  end

  config.enabled = true

  config.log_silently = false
  config.run_on_precompile = false

  # Invalidate a file on a cdn after uploading files
  # config.cdn_distribution_id = "12345"
  # config.invalidate = ['file1.js']

  # Increase upload performance by configuring your region
  config.fog_region = 'us-west-1'
  #
  # Don't delete files from the store
  # config.existing_remote_files = "keep"
  #
  # Automatically replace files with their equivalent gzip compressed version
  config.gzip_compression = true
  #
  # Use the Rails generated 'manifest.yml' file to produce the list of files to
  # upload instead of searching the assets directory.
  config.manifest = true

  config.always_upload = ["manifest.json"]

  # Fail silently.  Useful for environments such as Heroku
  # config.fail_silently = true
end
