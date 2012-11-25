class Company < ActiveRecord::Base
  URL_REGEXP = URI::regexp(%w(http https))

  attr_accessible :creator_id, :deleted_at, :description, :url, :email, :name

  belongs_to :creator, class_name: "User"
  has_many :locations

  before_validation :add_default_url_scheme

  validates_presence_of :name, :description
  validates :email, email: true, allow_blank: true
  validate :validate_url_format

  acts_as_paranoid

  private

  def add_default_url_scheme
    if url.present? && !/^(http|https):\/\//.match(url)
      new_url = "http://#{url}"
      self.url = new_url if URL_REGEXP.match(new_url)
    end
  end

  def validate_url_format
    return if url.blank?
    unless URL_REGEXP.match(url)
      errors.add(:url, "must be a valid URL")
      return
    end

    URI.parse(url)
    true
  rescue URI::InvalidURIError
    errors.add(:url, "must be a valid URL")
  end
end
