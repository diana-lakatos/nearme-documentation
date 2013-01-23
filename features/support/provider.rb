module Provider

  def authentication_link_text_for_provider(provider)
     symbol_to_name(normalize_symbol(provider))
  end

  private 

  def normalize_symbol(provider)
    provider.downcase.to_sym
  end

  def symbol_to_name(symbol)
    case symbol
    when :linkedin
      "LinkedIn"
    else
      symbol.to_s.titleize
    end
  end
end
World(Provider)
