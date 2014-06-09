class Industry < ActiveRecord::Base

  has_metadata :without_db_column => true

  attr_accessible :name, :company_ids, :user_ids

  validates_presence_of :name
  validates :name, :uniqueness => true

  has_many :company_industries
  has_many :companies, :through => :company_industries
  has_many :locations, :through => :companies
  has_many :listings, :through => :locations, class_name: 'Transactable'

  scope :with_listings, -> { joins(:listings).merge(Transactable.searchable).group('industries.id HAVING count(transactables.id) > 0') }
  scope :ordered, -> { order('name asc') }


end
