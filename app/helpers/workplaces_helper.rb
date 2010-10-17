module WorkplacesHelper
  def workplace_inline_description(workplace)
    raw(truncate(strip_tags(workplace.company_description_html), :length => 65))
  end
end
