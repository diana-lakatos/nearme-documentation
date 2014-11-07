class CertificateRequest < Form
  attr_accessor :domain, :country, :state, :city, :organization, :department, :common_name, :email

  validates :domain, :country, :state, :city,
            :organization, :department,
            :common_name, :email,
            :presence => true

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
      :country => self.country,
      :state => self.state,
      :city => self.city,
      :organization => self.organization,
      :department => self.department,
      :common_name => self.common_name,
      :email => self.email
    }
  end
end
