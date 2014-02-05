class Industry < ActiveRecord::Base

  attr_accessible :name, :company_ids, :user_ids

  validates_presence_of :name
  validates :name, :uniqueness => true
  
  has_many :company_industries

  has_many :companies, 
    :through => :company_industries

  has_many :locations, 
    :through => :companies

  has_many :listings, 
    :through => :locations

  scope :with_listings, joins(:listings).merge(Listing.searchable).group('industries.id HAVING count(listings.id) > 0')
  scope :ordered, order('name asc')

  after_commit :populate_companies_industries_metadata!

  def populate_companies_industries_metadata!
    companies.find_each(&:populate_industries_metadata!)
  end

end
