class AddColumnsToUsers < ActiveRecord::Migration

  class Instance < ActiveRecord::Base
    serialize :user_required_fields, Array
  end

  def change
    change_table :users do |t|
      t.string :first_name, :middle_name, :last_name, :gender, :drivers_licence_number, :gov_number, :twitter_url, :linkedin_url, :facebook_url, :google_plus_url
    end
    add_column :instances, :user_required_fields, :text
    Instance.where(user_info_in_onboarding_flow: true).find_each do |i|
      i.update_attribute(:user_required_fields, ['name', 'biography', 'avatar'])
    end

  end
end
