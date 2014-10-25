class WrapChargeResponseInResponseObject < ActiveRecord::Migration
  class Charge < ActiveRecord::Base
    acts_as_paranoid
    scope :successful, -> { where(:success => true) }
    serialize :response, Hash
    attr_encrypted :response, :key => DesksnearMe::Application.config.secret_token, marshal: true
  end

  def up
    Charge.successful.where.not(encrypted_response: nil).find_each do |charge|
      begin
        return if charge.response.class == ActiveMerchant::Billing::Response
        charge.response = ActiveMerchant::Billing::Response.new(true, 'OK', charge.response)
        charge.save!
      rescue
        next
      end
    end
  end

  def down
    Charge.successful.where.not(encrypted_response: nil).find_each do |charge|
      begin
        return if charge.response.class != ActiveMerchant::Billing::Response
        charge.response = charge.response.params
        charge.save!
      rescue
        next
      end
    end
  end
end
