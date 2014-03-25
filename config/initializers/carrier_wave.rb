CarrierWave.configure do |config|

  config.fog_credentials = {
    :provider                   => 'AWS',
    :aws_access_key_id          => 'AKIAI5EVP6HB47OZZXXA',
    :aws_secret_access_key      => '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'
  }
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000, public'}

  if ENV['DEMO']
    config.fog_directory          = 'desksnearme.demo-standard'
    config.asset_host             = 'https://s3.amazonaws.com/desksnearme.demo-standard'
    config.storage                = :fog
  else
    case Rails.env
    when "production"
      config.fog_directory        = 'desksnearme.production'
      config.asset_host           = 'https://s3.amazonaws.com/desksnearme.production'
      config.storage              = :fog
    when "staging"
      config.fog_directory        = 'desksnearme.staging-prod-copy'
      config.asset_host           = 'https://s3.amazonaws.com/desksnearme.staging-prod-copy'
      config.storage              = :fog
    else
      config.storage              = :file
    end
  end

end

