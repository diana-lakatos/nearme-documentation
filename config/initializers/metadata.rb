require "#{Rails.root}/app/models/metadata/base.rb"
ActiveRecord::Base.send :include, Metadata::Base
