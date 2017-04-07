# frozen_string_literal: true
class FixTosForToodooloo < ActiveRecord::Migration
  def change
    InstanceView.where(path: 'api/v4/users/super_trash/tos_form').find_each do |iv|
      iv.update_attribute(:body, iv.body.gsub('user[accept_terms_of_service]', 'form[accept_terms_of_service]'))
    end
  end
end
