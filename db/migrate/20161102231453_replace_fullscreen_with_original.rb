# frozen_string_literal: true
class ReplaceFullscreenWithOriginal < ActiveRecord::Migration
  def change
    InstanceView.find_each do |iv|
      iv.update_attribute(:body, iv.body.gsub('photo.fullscreen', 'photo.original')) if iv.body.include?('photo.fullscreen')
    end
  end
end
