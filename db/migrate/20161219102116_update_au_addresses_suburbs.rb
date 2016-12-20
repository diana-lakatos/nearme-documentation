class UpdateAuAddressesSuburbs < ActiveRecord::Migration
  def change
    Instance.find(194).set_context!

    Address.where(suburb: nil).find_each do |address|
      address.parse_address_components!
      address.save
    end
  end
end
