module LiquidVariableExtensions

  def render(context)
    original_text = super(context)

    if original_text.is_a?(String)
      "".html_safe + original_text
    else
      original_text
    end
  end

end

class Liquid::Variable
  prepend LiquidVariableExtensions
end
