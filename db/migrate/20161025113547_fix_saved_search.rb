class FixSavedSearch < ActiveRecord::Migration
  def up
    searches = SavedSearch.unscoped.where("query ilike '%per_page=50.%' or query ilike '%per_page=20.%'")
    searches.each do |search|
      search.query.gsub!(/per_page=\d\d\.\w+(,\w+)?/, 'per_page=50')
      search.save!
    end
  end
end
