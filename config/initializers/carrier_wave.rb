CarrierWave.configure do |config|
  if Rails.env.production? || Rails.env.development?

    config.fog_credentials = {
      :provider                 => 'AWS',
      :aws_access_key_id        => 'AKIAILGH3PESU3PCUJEQ',
      :aws_secret_access_key    => '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'
    }
    config.fog_directory        = 'desksnearme.production'
    config.fog_host             = 'https://s3.amazonaws.com/desksnearme.production'

  else
    config.storage = :file
  end
end
