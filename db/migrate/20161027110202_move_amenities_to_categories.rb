class MoveAmenitiesToCategories < ActiveRecord::Migration
  class ListingAmenity < ActiveRecord::Base
    belongs_to :listing, class_name: 'Transactable'
    belongs_to :amenity
  end

  class LocationAmenity < ActiveRecord::Base
    belongs_to :location
    belongs_to :amenity
  end

  class Amenity < ActiveRecord::Base
    belongs_to :amenity_type
    has_many :amenity_holders, dependent: :destroy
    has_many :listings, through: :amenity_holders, source: :holder, source_type: 'Transactable', inverse_of: :amenities, class_name: 'Transactable'
    has_many :locations, through: :amenity_holders, source: :holder, source_type: 'Location', inverse_of: :amenities, class_name: 'Location'

    def category
      self[:category] || 'Other'
    end
  end

  class AmenityHolder < ActiveRecord::Base
    acts_as_paranoid

    belongs_to :amenity, touch: true
    belongs_to :holder, polymorphic: true, touch: true
  end

  class AmenityType < ActiveRecord::Base
    self.inheritance_column = :_type_disabled
    auto_set_platform_context
    scoped_to_platform_context

    validates_presence_of :name
    validates :name, uniqueness: { scope: :instance_id }

    belongs_to :instance
    has_many :amenities, -> { order 'amenities.name ASC' }, dependent: :destroy
    has_many :locations, through: :amenities
    has_many :listings, through: :amenities, class_name: 'Transactable'
  end

  def up
    Instance.where(id: AmenityType.uniq.pluck(:instance_id)).find_each do |instance|
      instance.set_context!
      next unless TransactableType.any?
      puts instance.name.to_s
      AmenityType.where(type: 'ListingAmenityType', instance_id: instance.id).find_each do |amenity_type|
        puts "\tProcessing #{amenity_type.name}"
        c = Category.where(instance_id: instance.id, name: amenity_type.name).first_or_create! do |c|
          c.multiple_root_categories = false
          puts "\t\t\tCreated new category"
        end
        c.transactable_types = TransactableType.all
        c.save!

        amenity_type.amenities.find_each do |amenity|
          puts "\t\t#{amenity.name}"
          nested_category = c.children.where(instance_id: instance.id, name: amenity.name).first_or_create! do
            puts "\t\t\t\tCreated new nested_category"
          end
          amenity.amenity_holders.find_each do |amenity_holder|
            CategoriesCategorizable.where(instance_id: instance.id, category: nested_category, categorizable: amenity_holder.holder).first_or_create! do
              puts "\t\t\tCreated category categorizable between #{amenity_holder.holder.name} and #{nested_category.name}"
            end
          end
        end
      end
    end
  end

  def down
  end
end
