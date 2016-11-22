# frozen_string_literal: true
class RemoveAmenitiesFromCacheInLiquidViews < ActiveRecord::Migration
  def change
    InstanceView.all.select { |lv| lv.body.include?('cache_for location, location.company, location.amenities') }.each do |iv|
      iv.update_attribute(:body, iv.body.gsub('{% cache_for location, location.company, location.amenities, location.availability, description %}', '{% cache_for location, location.company, location.availability, description %}'))
    end
  end
end
