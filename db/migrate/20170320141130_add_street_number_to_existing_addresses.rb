class AddStreetNumberToExistingAddresses < ActiveRecord::Migration
  def self.up
    address_count = Address.unscoped.where('deleted_at is null').count
    address_index = 0

    Instance.find_each do |instance|
      instance.set_context!

      Address.find_each do |address|
        puts "At address #{address_index+1} out of #{address_count}" if address_index % 1000 == 0
        address_index += 1

        data_parser = Address::GoogleGeolocationDataParser.new(address.address_components)
        address.update_column(:street_number, data_parser.fetch_address_component('street_number'))
      end

      if instance.searchable_classes.include?(User)
        ElasticInstanceIndexerJob.perform(update_type: 'rebuild', only_classes: ['User'])
      end
    end
  end

  def self.down
    Address.unscoped.where('deleted_at is null').update_all(street_number: nil)
  end
end
