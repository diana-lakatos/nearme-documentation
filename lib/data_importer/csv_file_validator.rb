class DataImporter::CsvFileValidator

  def initialize(csv_file_path, *mandatory_fields)
    @csv_file_path    = csv_file_path
    @mandatory_fields = mandatory_fields
  end

  def strip_invalid_rows
    if @mandatory_fields.blank?
      [CSV.new(open(@csv_file_path), headers: true), []]
    else
      csv_file = CSV.new(open(@csv_file_path), headers: true)
      row_num = 0
      invalid_rows = []
      valid_rows   = []

      csv_file.each do |row|
        row_num += 1
        errors = @mandatory_fields.inject([]) do |ar, attr|
          ar << "#{attr} is blank" if row[attr].blank?
          ar
        end
        errors.present? ? invalid_rows << "#{row_num}. #{errors.join(', ')}" : valid_rows << row
      end

      filtered_csv = CSV.generate do |csv|
        csv << csv_file.headers if csv_file.headers.is_a?(Array)
        valid_rows.each { |row| csv << row }
      end

      [CSV.new(filtered_csv), invalid_rows]
    end
  end

end
