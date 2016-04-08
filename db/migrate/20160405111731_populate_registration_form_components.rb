require Rails.root.join('lib', 'utils', 'form_components_creator.rb')

class PopulateRegistrationFormComponents < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      puts "Creating Registration Form Components for #{i.name}"
      i.set_context!
      Utils::InstanceSellerProfileCreator.new(InstanceProfileType.seller.first).create_seller_registration!
      Utils::InstanceProfileCreator.new(InstanceProfileType.default.first).create_default_registration!
      Utils::InstanceBuyerProfileCreator.new(InstanceProfileType.buyer.first).create_buyer_registration!
    end
  end

  def down
  end
end
