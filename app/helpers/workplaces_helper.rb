module WorkplacesHelper
  def workplace_inline_description(workplace, length = 65)
    raw(truncate(strip_tags(workplace.company_description_html), :length => length))
  end
end
