class MigrateMerchantAccountToMerchantAccountOwners < ActiveRecord::Migration
  class MerchantAccount::StripeConnectMerchantAccount < MerchantAccount
    has_one :current_address, class_name: 'Address', as: :entity, validate: false
    has_many :owners, -> { order(:id) }, class_name: 'MerchantAccountOwner::StripeConnectMerchantAccountOwner',
                                       foreign_key: 'merchant_account_id', dependent: :destroy

    ATTRIBUTES = %w(account_type currency bank_routing_number bank_account_number tos ssn_last_4).freeze
    ACCOUNT_TYPES = %w(individual company).freeze

    include MerchantAccount::Concerns::DataAttributes

  end

  def up
    ids = MerchantAccount::StripeConnectMerchantAccount.all.map(&:instance_id).uniq
    Instance.where(id: ids).find_each do |i|
      i.set_context!
      puts "Migration Stripe Merchant account for #{i.name}"
      MerchantAccount::StripeConnectMerchantAccount.all.each do |m|
        m.skip_validation = true
        owner = m.owners.first || m.owners.build
        owner.first_name = m.data['first_name']
        owner.last_name = m.data['last_name']
        owner.personal_id_number = m.data['personal_id_number']
        owner.business_vat_id = m.data['business_vat_id']
        owner.business_tax_id = m.data['business_tax_id']
        owner.current_address = m.current_address

        owner.save(validate: false)
      end
    end
  end

  def down
  end
end
