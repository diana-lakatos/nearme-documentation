module ActiveRecord::ConnectionAdapters::Quoting
  # Escape special characters (% and _) for use in a LIKE operator.
  def quote_like_string(string, escape_char = '\\')
    string.gsub(escape_char, escape_char * 2).gsub(/([\_\%])/, "#{escape_char}\1")
  end
end
