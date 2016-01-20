class DataImporter::CsvFileValidator

  def initialize(csv_file_path, *mandatory_fields)
    @csv_file_path    = csv_file_path
    @mandatory_fields = mandatory_fields
  end

  def strip_invalid_rows
    if @mandatory_fields.blank?
      [csv_open_with_encoding_conversion(@csv_file_path, headers: true), []]
    else
      csv_file = csv_open_with_encoding_conversion(@csv_file_path, headers: true)
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

  def csv_open_with_encoding_conversion(file_path, *options)
    file = open(file_path)
    contents = file.read
    file.close

    forced_contents = contents.encode('UTF-8', undef: :replace, replace: '')

    detection = CharlockHolmes::EncodingDetector.detect(contents)
    if detection.present?
      begin
        utf8_encoded_content = CharlockHolmes::Converter.convert contents, detection[:encoding], 'UTF-8'
      rescue
        utf8_encoded_content = forced_contents
      end
    else
      utf8_encoded_content = forced_contents
    end

    CSV.new(utf8_encoded_content, *options)
  end

end
