namespace :reencrypt do

  desc "Decrypt and encrypt again data with new secret_token. Provide OLD_KEY, optional INSTANCE_ID"
  task :all_data, [:old_key, :instance_id] => :environment do |t, args|
    old_key = ENV['OLD_KEY'].presence || args[:old_key]
    return p 'Variable OLD_KEY not provided.' if old_key.blank?

    PlatformContext.clear_current

    instance_id = ENV['INSTANCE_ID'].presence || args[:instance_id]

    Utils::Reencryptor.new(old_key: old_key, instance_id: instance_id).process_data!
  end

end