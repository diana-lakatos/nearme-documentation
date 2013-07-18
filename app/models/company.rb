class Company < ActiveRecord::Base
  URL_REGEXP = URI::regexp(%w(http https))

  attr_accessible :creator_id, :deleted_at, :description, :url, :email, :name, :mailing_address, :paypal_email, :industry_ids, :locations_attributes

  belongs_to :creator, class_name: "User"
  belongs_to :instance

  has_many :locations,
           dependent: :destroy,
           inverse_of: :company

  has_many :listings,
           through: :locations

  has_many :reservations,
           through: :listings

  has_many :reservation_charges,
           through: :reservations

  has_many :company_industries
  has_many :industries, :through => :company_industries

  before_validation :add_default_url_scheme

  after_save :notify_user_about_change
  after_destroy :notify_user_about_change

  validates_presence_of :name, :industries
  validates_length_of :description, :maximum => 250, :if => lambda { |company| (company.instance.nil? || company.instance.is_desksnearme?) }
  validates :email, email: true, allow_blank: true
  validate :validate_url_format
  
  acts_as_paranoid

  accepts_nested_attributes_for :locations

  def notify_user_about_change
    creator.try(:touch)
  end

  def self.xml_attributes
    [:name, :description, :email]
  end

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
