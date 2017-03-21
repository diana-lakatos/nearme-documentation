# frozen_string_literal: true
class LitvaultSetEsForPeopleSearch < ActiveRecord::Migration
  def up
    update_user_profiles(search_engine: 'elasticsearch')
  end

  def down
    update_user_profiles(search_engine: 'postgresql')
  end

  private

  def update_user_profiles(attributes)
    Instance.where(id: 198).each do |instance|
      instance
        .instance_profile_types
        .each { |profile| profile.update_attributes(attributes) }
    end
  end
end
