CarrierWave.configure do |config|
  if Rails.env.production?
    config.storage              = :s3
    config.s3_access_key_id     = 'AKIAILGH3PESU3PCUJEQ'
    config.s3_secret_access_key = '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'
    config.s3_bucket            = 'desksnearme.production'
  else
    config.storage = :file
  end
end
