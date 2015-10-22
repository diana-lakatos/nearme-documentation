module AvailabilitySupport
  def availability_data_from_table(table)
    table.hashes.map do |rule|
      { open: rule['Open Time'], close: rule['Close Time'], days: rule['Days'].split(',').map(&:to_i) }
    end
  end
end

World(AvailabilitySupport)
