# frozen_string_literal: true
class InstanceAdmin::Manage::InstanceProfileTypes::CustomValidatorsController < InstanceAdmin::CustomValidatorsController
  protected

  def resource_class
    InstanceProfileType
  end

  def available_attributes
    @attributes = [
      :first_name, :middle_name, :last_name, :name, :phone, :mobile_number, :country_name, :current_location,
      :company_name, :avatar, :password
    ]
  end
end
