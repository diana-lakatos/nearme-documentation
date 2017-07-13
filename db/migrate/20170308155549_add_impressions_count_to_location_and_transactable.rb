class AddImpressionsCountToLocationAndTransactable < ActiveRecord::Migration
  class Impression < ActiveRecord::Base
  end
  def change
    add_column :locations, :impressions_count, :integer, null: false, default: 0
    add_column :transactables, :impressions_count, :integer, null: false, default: 0

    locations_count = Location.unscoped.where('deleted_at is null').count
    transactables_count = Transactable.unscoped.where('deleted_at is null').count
    locations_index = 0
    transactables_index = 0

    Instance.find_each do |instance|
      instance.set_context!

      Location.find_each do |location|
        puts "At location #{locations_index+1} out of #{locations_count}" if locations_index % 1000 == 0
        locations_index += 1

        impressions_count = Impression.where(impressionable: location).count
        location.update_column(:impressions_count, impressions_count)
      end
    end

    Instance.find_each do |instance|
      instance.set_context!

      Transactable.find_each do |transactable|
        puts "At transactable #{transactables_index+1} out of #{transactables_count}" if transactables_index % 1000 == 0
        transactables_index += 1

        impressions_count = Impression.where(impressionable: transactable).count
        transactable.update_column(:impressions_count, impressions_count)
      end
    end
  end
end
