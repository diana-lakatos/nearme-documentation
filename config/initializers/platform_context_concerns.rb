ActiveRecord::Base.send :include, PlatformContext::DefaultScoper
ActiveRecord::Base.send :include, PlatformContext::ForeignKeysAssigner
