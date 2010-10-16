CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage              = :s3
    config.s3_access_key_id     = 'AKIAIZ5FVYS75LSDRTYQ'
    config.s3_secret_access_key = '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'
    config.s3_bucket            = 'desksnearme'
  else
    config.storage = :file
  end
end

