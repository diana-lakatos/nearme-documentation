class UnitsOfMeasureValidator < ActiveModel::EachValidator
  def validate(record)
    record.errors[:unit_of_measure] << (options[:message] || 'is invalid') unless DimensionsTemplate::UNITS_OF_MEASURE.keys.include?(record.unit_of_measure)
    record.errors[:weight_unit] << (options[:message] || 'is invalid') if !DimensionsTemplate::UNITS_OF_MEASURE['imperial']['weight'].include?(record.weight_unit) && record.unit_of_measure == 'imperial'
    record.errors[:weight_unit] << (options[:message] || 'is invalid') if !DimensionsTemplate::UNITS_OF_MEASURE['metric']['weight'].include?(record.weight_unit) && record.unit_of_measure == 'metric'
    record.errors[:height_unit] << (options[:message] || 'is invalid') if !DimensionsTemplate::UNITS_OF_MEASURE['imperial']['length'].include?(record.height_unit) && record.unit_of_measure == 'imperial'
    record.errors[:height_unit] << (options[:message] || 'is invalid') if !DimensionsTemplate::UNITS_OF_MEASURE['metric']['length'].include?(record.height_unit) && record.unit_of_measure == 'metric'
    record.errors[:width_unit] << (options[:message] || 'is invalid') if !DimensionsTemplate::UNITS_OF_MEASURE['imperial']['length'].include?(record.width_unit) && record.unit_of_measure == 'imperial'
    record.errors[:width_unit] << (options[:message] || 'is invalid') if !DimensionsTemplate::UNITS_OF_MEASURE['metric']['length'].include?(record.width_unit) && record.unit_of_measure == 'metric'
    record.errors[:depth_unit] << (options[:message] || 'is invalid') if !DimensionsTemplate::UNITS_OF_MEASURE['imperial']['length'].include?(record.depth_unit) && record.unit_of_measure == 'imperial'
    record.errors[:depth_unit] << (options[:message] || 'is invalid') if !DimensionsTemplate::UNITS_OF_MEASURE['metric']['length'].include?(record.depth_unit) && record.unit_of_measure == 'metric'
  end
end
