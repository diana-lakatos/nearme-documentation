class UpdateAuAddressesSuburbs < ActiveRecord::Migration
  def change
    i = Instance.find_by(id: 194)
    return true if i.nil?
    i.set_context!

    Address.where(suburb: nil).find_each do |address|
      address.parse_address_components!
      address.save
    end
  end
end
