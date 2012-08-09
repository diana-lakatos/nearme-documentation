CarrierWave.configure do |config|
  if Rails.env.production? || Rails.env.staging? || Rails.env.development?

    config.fog_credentials = {
      :provider                 => 'AWS',
      :aws_access_key_id        => 'AKIAI5EVP6HB47OZZXXA',
      :aws_secret_access_key    => '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'
    }
    config.fog_directory        = 'desksnearme.production'
    config.fog_host             = 'https://s3.amazonaws.com/desksnearme.production'
    config.storage = :fog

  else
    config.storage = :file
  end
end
