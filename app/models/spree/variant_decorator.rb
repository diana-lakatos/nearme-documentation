Spree::Variant.class_eval do
  include Spree::Scoper
  include ActiveModel::Validations

  belongs_to :company

  validates_with UnitsOfMeasureValidator, :attributes => [:unit_of_measure, :weight_unit, :height_unit, :width_unit, :depth_unit]

  before_save :update_native_fields_from_user_fields

  def update_native_fields_from_user_fields
    self.weight = MetricsConverter.new(self.weight_user, self.weight_unit).convert_weight_value_to_oz_by_unit_type
    self.height = MetricsConverter.new(self.height_user, self.height_unit).convert_length_value_to_inch_by_unit_type
    self.width = MetricsConverter.new(self.width_user, self.width_unit).convert_length_value_to_inch_by_unit_type
    self.depth = MetricsConverter.new(self.depth_user, self.depth_unit).convert_length_value_to_inch_by_unit_type

    true
  end

end

