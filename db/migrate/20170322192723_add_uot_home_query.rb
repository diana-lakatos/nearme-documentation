# frozen_string_literal: true
class AddUotHomeQuery < ActiveRecord::Migration
  def up # rubocop:disable Metrics/MethodLength
    query = <<-EOQ
    query UOTHomeQuery{
      featured_smes:users(take: 6, filters: [FEATURED]){
        id
        profile_path
        avatar_url_big
        name
        bio: profile_property(profile_type: "buyer", name: "bio")
      }
    }
    EOQ

    GraphQuery.create!(instance_id: instance.id, name: 'uot_home', query_string: query) if instance
  end

  def down
    GraphQuery.find_by(instance_id: instance.id, name: 'uot_home').destroy if instance
  end

  private

  def instance
    Instance.find_by(id: 195)
  end
end
