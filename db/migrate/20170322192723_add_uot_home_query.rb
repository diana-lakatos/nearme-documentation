class AddUotHomeQuery < ActiveRecord::Migration
  def up
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

    GraphQuery.create!(
      instance_id: 195,
      name: 'uot_home',
      query_string: query
    )
  end

  def down
    GraphQuery.find_by(instance_id: 195, name: 'uot_home').destroy
  end
end
