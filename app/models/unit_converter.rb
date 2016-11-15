module UnitConverter
  UNITS_OF_MEASURE = {
    'imperial' => {
      'length' => %w(in ft),
      'weight' => %w(oz lb)
    },
    'metric' => {
      'length' => %w(cm m),
      'weight' => %w(g kg)
    }
  }.freeze

  def common_unit?
    [width_unit, height_unit, depth_unit].uniq.size == 1
  end

  def common_distance_unit
    if common_unit?
      width_unit
    else
      imperial? ? 'in' : 'cm'
    end
  end

  def convert(dimension, from_unit)
    case from_unit
    when 'm'
      dimension * 100
    when 'ft'
      dimension * 12
    else
      dimension
    end
  end

  def imperial?
    unit_of_measure == 'imperial'
  end

  %w(depth height width).each do |dimension|
    define_method "converted_#{dimension}" do
      if common_unit?
        self[dimension]
      else
        convert(self[dimension], self["#{dimension}_unit"])
      end
    end
  end

end
