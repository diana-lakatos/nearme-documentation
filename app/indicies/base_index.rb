module BaseIndex
  module_function

  PUNCTUATION = ". , / - _ \\ + = ~ * % $ !".split(" ").freeze

  def default_index_options
    { number_of_shards: 1 }
  end

  def override_text_values(record)
    new_values = {}
    string_keys = record.class.columns_hash.map {|k,v| k if %w(text string).include?(v.type.to_s) }.compact

    string_keys.each do |key|
      new_values[key] = sanitize_string(record.send(key)) if record.send(key).present? && record.send(key).is_a?(String)
    end

    return new_values.symbolize_keys
  end

  def sanitize_string(string)
    @new_string = nil

    PUNCTUATION.each do |punctuation|
      if string.present?
        @new_string ||= string
        @new_string = @new_string.gsub(punctuation, "")
      end
    end

    return @new_string
  end
end
