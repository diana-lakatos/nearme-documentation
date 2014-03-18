require "#{Rails.root}/app/models/platform_context/default_scoper.rb"
require "#{Rails.root}/app/models/platform_context/foreign_keys_assigner.rb"
ActiveRecord::Base.send :include, PlatformContext::DefaultScoper
ActiveRecord::Base.send :include, PlatformContext::ForeignKeysAssigner
