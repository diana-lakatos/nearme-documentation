class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string   :name,        limit: 255
      t.string   :abbr,        limit: 255
      t.integer  :country_id, index: true
      t.datetime :updated_at
    end

    Spree::State.all.each do |state|
      State.create(name: state.name, abbr: state.abbr, country_id: Country.find_by_iso(state.country.iso).try(:id) )
    end
  end
end
