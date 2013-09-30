# Only run this initializer if AssetSync has been required (e.g. asset bundler group loaded)
if defined?(AssetSync)
  AssetSync.configure do |config|
    config.fog_provider = 'AWS'
    config.aws_access_key_id = 'AKIAI5EVP6HB47OZZXXA'
    config.aws_secret_access_key = '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'
    # To use AWS reduced redundancy storage.
    # config.aws_reduced_redundancy = true

    case Rails.env
    when "production"
      config.fog_directory        = 'desksnearme.production'
    when "staging"
      config.fog_directory        = 'desksnearme.staging-prod-copy'
    end

    # Invalidate a file on a cdn after uploading files
    # config.cdn_distribution_id = "12345"
    # config.invalidate = ['file1.js']

    # Increase upload performance by configuring your region
    # config.fog_region = 'eu-west-1'
    #
    # Don't delete files from the store
    # config.existing_remote_files = "keep"
    #
    # Automatically replace files with their equivalent gzip compressed version
    # config.gzip_compression = true
    #
    # Use the Rails generated 'manifest.yml' file to produce the list of files to
    # upload instead of searching the assets directory.
    # config.manifest = true
    #
    # Fail silently.  Useful for environments such as Heroku
    # config.fail_silently = true
  end
end
