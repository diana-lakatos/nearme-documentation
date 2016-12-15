module AttributesParserHelper
  # this is needed to support data attributes with hyphen, i.e. input_html_data-custom-attr
  # original expression starts with /(\w+ , I've just changed it to /([\w-]+ to not ignore
  # tag if hyphen is included
  TagAttributesWithHypen = /([\w-]+)\s*\:\s*(#{Liquid::QuotedFragment})/

  def create_initial_hash_from_liquid_tag_markup(markup)
    hash = {}
    markup.scan(TagAttributesWithHypen) do |key, value|
      new_key = key.sub(/^["']/, '')
      new_key = new_key.sub(/["']$/, '')
      hash[new_key] = value
    end
    hash
  end

  def normalize_liquid_tag_attributes(hash, context, prefixes = [])
    # We don't want to change the original hash because it's 
    # reused in all fields_for iterations
    hash_result = hash.try(:dup) || {}

    # inicjalize variables for each prefix, if prefix is 'html' then create '@html_attributes' variable
    prefixes.each { |p| instance_variable_set(:"@#{p}_attributes", {}) }
    hash_result.each do |key, value|
      next unless String === value
      # if value starts with @ then get value from context as it's variable, otherwise remove trailing quotes
      value = value.sub(/^["']/, '').sub(/["']$/, '')
      value = if value[0] == '[' && value[-1] == ']'
                value = value[1..-2].split(',').map { |v| values_value(v, context) }
              else
                values_value(value, context)
      end

      # check if key starts with a prefix - if yes, then we should create nested hash
      if (prefix = prefixes.detect { |p| key =~ /^#{p}-/ }).present?
        hash_result.delete(key)
        # store in proper hash but not under %prefix%_key, but just as a key
        instance_variable_get(:"@#{prefix}_attributes")[key.sub(/^#{prefix}-/, '')] = value
        # otherwise just overwrite value in case there are quotes
      else
        hash_result[key] = value
      end
    end
    # now build proper nested hash

    prefixes.each { |p| hash_result[p.to_sym] = instance_variable_get(:"@#{p}_attributes") }
    hash_result.deep_symbolize_keys
  end

  def values_value(value, context)
    new_value = value.sub(/^["']/, '').sub(/["']$/, '').strip
    case new_value
    when /^@/
      context[new_value].try(:source).presence || context[new_value]
    when 'false'
      false
    else
      new_value
    end
  end
end
