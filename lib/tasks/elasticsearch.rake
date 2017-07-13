ENV['RAILS_ENV'] ||= 'development'

namespace :elasticsearch do
  desc 'create new_index for instance'
  task :create_index, [:instance_id] => :environment do |_t, args|
    Elastic::InstanceDocuments::Rebuild.new(args[:instance_id]).perform
  end
end
