# frozen_string_literal: true
class UpdateLinkToRegistrationInLiquidViews < ActiveRecord::Migration
  def up
    InstanceView.where('body ilike ?', '%new_user_registration%').find_each do |iv|
      iv.update_column(:body, iv.body.gsub('new_user_registration', 'new_api_user'))
    end
    InstanceView.where('body ilike ?', '%users/sign_up%').find_each do |iv|
      iv.update_column(:body, iv.body.gsub('users/sign_up', 'api/users/new'))
    end
    InstanceView.where('body ilike ?', '%/users?%').find_each do |iv|
      iv.update_attribute(:body, iv.body.gsub('/users?', '/api/users/new?'))
    end
    Page.where('content ilike ?', '%users/sign_up%').find_each do |p|
      p.update_attribute(:content, p.content.gsub('users/sign_up', 'api/users/new'))
    end
    Page.where('content ilike ?', '%/users?%').find_each do |p|
      p.update_attribute(:content, p.content.gsub('/users?', '/api/users/new?'))
    end
  end

  def down
  end
end
