# frozen_string_literal: true
class CertificateRequest < Form
  attr_accessor :domain, :country, :state, :city, :organization, :department, :common_name, :email

  validates :domain, :country, :state, :city,
            :organization, :department,
            :common_name, :email,
            presence: true

  def initialize(params = {})
    self.domain = params[:common_name]
    self.country = params[:country]
    self.state = params[:state]
    self.city = params[:city]
    self.organization = params[:organization]
    self.department = params[:department]
    self.common_name = params[:common_name]
    self.email = params[:email]
  end

  def attributes
    {
      country: country,
      state: state,
      city: city,
      organization: organization,
      department: department,
      common_name: common_name,
      email: email
    }
  end
end
