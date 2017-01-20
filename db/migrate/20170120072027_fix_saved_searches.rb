class FixSavedSearches < ActiveRecord::Migration
  def up
    PlatformContext.clear_current
    SavedSearch.distinct.pluck(:instance_id).each do |instance_id|
      next unless instance = Instance.find_by(id: instance_id)
      instance.set_context!
      SavedSearch.find_each do |ss|
        ss.params["sort"] = "created_at_desc"
        ss.params["price[max]"] = ss.params["price[max]"].to_f if ss.params["price[max]"]
        ss.params["price[min]"] = ss.params["price[min]"].to_f if ss.params["price[min]"]
        ss.params["per_page"] = instance_id == 130 ? 50 : 20
        ss.query = ss.params.to_query
        ss.save!
      end
    end
  end
end
