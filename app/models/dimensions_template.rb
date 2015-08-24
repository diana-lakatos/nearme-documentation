class DimensionsTemplate < ActiveRecord::Base

  auto_set_platform_context
  scoped_to_platform_context
  acts_as_paranoid

  UNITS_OF_MEASURE = {
    'imperial' => {
      'length' => ['in', 'ft'],
      'weight' => ['oz', 'pound'],
    },
    'metric' => {
      'length' => ['cm', 'm'],
      'weight' => ['g', 'kg'],
    }
  }

  belongs_to :instance

  belongs_to :creator, :foreign_key => :creator_id, class_name: User

  belongs_to :entity, polymorphic: true

  validates_presence_of  :name, :weight, :height, :width, :depth

  validates_with UnitsOfMeasureValidator, :attributes => [:unit_of_measure, :weight_unit, :height_unit, :width_unit, :depth_unit]

  validates_numericality_of :weight, :height, :width, :depth, greater_than: 0

end
