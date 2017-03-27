# frozen_string_literal: true
class FixAsocciationToAssociation < ActiveRecord::Migration
  def up
    PlatformContext.current = nil
    InstanceView.where('body like ?', '%asocciation%').each { |iv| iv.update_attribute(:body, iv.body.gsub('asocciation', 'association')) }
  end

  def down
  end
end
