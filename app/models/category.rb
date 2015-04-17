class Category < ActiveRecord::Base

  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context
  acts_as_nested_set dependent: :destroy

  has_many :categories_transactables
  has_many :transactables, through: :categories_transactables

  # Validation
  validates :name, presence: true


  # Polymprophic association to TransactableType and ProductType
  belongs_to :categorable, polymorphic: true
  belongs_to :instance

  before_save :set_permalink
  after_save :update_children_permalink

  def child_index=(idx)
    unless self.new_record?
      if parent
        move_to_child_with_index(parent, idx.to_i)
      else
        move_to_root
      end
    end
  end

  def encoded_permalink
    permalink.gsub("/", "%2F")
  end

  def update_children_permalink
    children.each { |c| c.save } if reload.children.any?
  end

  def set_permalink
    if parent.present?
      self.permalink = [parent.permalink, name.to_url].join('/')
    else
      self.permalink = name.to_url
    end
  end

  def to_liquid
    CategoryDrop.new(self)
  end
end



