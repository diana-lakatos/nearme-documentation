class Industry < ActiveRecord::Base

  has_metadata :without_db_column => true

  auto_set_platform_context
  scoped_to_platform_context

  # attr_accessible :name, :company_ids, :user_ids

  validates_presence_of :name
  validates :name, uniqueness: {scope: :instance_id}

  has_many :company_industries
  has_many :companies, :through => :company_industries
  has_many :locations, :through => :companies
  has_many :listings, :through => :locations, class_name: 'Transactable'

  scope :with_listings, -> { joins(:listings).merge(Transactable.searchable).group('industries.id HAVING count(transactables.id) > 0') }
  scope :ordered, -> { order('name asc') }

  def self.csv_fields
    {name: 'Industry'}
  end

end
