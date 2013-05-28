module AvailabilitySupport
  def availability_data_from_table(table)
    days = {}
    (0..6).to_a.each do |day|
      days[day] = {}
    end

    table.hashes.each do |rule|
      days[rule['Day'].to_i] = if rule['Available'] != 'No'
        { :open => rule['Open Time'], :close => rule['Close Time'] }
      else
        {}
      end
    end

    days
  end
end

World(AvailabilitySupport)
