require "#{Rails.root}/lib/carrier_wave/delayed_versions.rb"
ActiveRecord::Base.send :include, CarrierWave::DelayedVersions
