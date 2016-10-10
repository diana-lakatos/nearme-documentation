class MetricsConverter
  def initialize(value, unit_type)
    @value = value
    @unit_type = unit_type
  end

  def convert_weight_value_to_oz_by_unit_type
    @value = @value.to_f
    case @unit_type
    when 'oz'
      @value
    when 'lb'
      (@value * 16).round(2)
    when 'g'
      (@value / 28.3495).round(2)
    when 'kg'
      (@value * 35.274).round(2)
    end
  end

  def convert_length_value_to_inch_by_unit_type
    @value = @value.to_f
    case @unit_type
    when 'in'
      @value
    when 'ft'
      (@value * 12).round(2)
    when 'cm'
      (@value / 2.54).round(2)
    when 'm'
      (@value * 39.3701).round(2)
    end
  end
end
