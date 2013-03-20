class Company < ActiveRecord::Base
  URL_REGEXP = URI::regexp(%w(http https))

  attr_accessible :creator_id, :deleted_at, :description, :url, :email, :name, :mailing_address, :paypal_email, :industry_ids, :locations_attributes

  belongs_to :creator, class_name: "User"

  has_many :locations,
           dependent: :destroy,
           inverse_of: :company

  has_many :company_industries
  has_many :industries, :through => :company_industries

  before_validation :add_default_url_scheme

  validates_length_of :description, :maximum => 250
  validates :email, email: true, allow_blank: true
  validate :validate_url_format
  
  validates_associated :locations

  acts_as_paranoid

  accepts_nested_attributes_for :locations

  private

  def add_default_url_scheme
    if url.present? && !/^(http|https):\/\//.match(url)
      new_url = "http://#{url}"
      self.url = new_url if URL_REGEXP.match(new_url)
    end
  end

  def validate_url_format
    return if url.blank?

    valid = URL_REGEXP.match(url)
    valid &&= begin
      URI.parse(url)
    rescue
      false
    end

    errors.add(:url, "must be a valid URL") unless valid
  end
end
