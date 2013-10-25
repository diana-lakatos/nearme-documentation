require 'singleton'

class EmailResolver < DbViewResolver
  include Singleton

  def find_mailers(name, prefix, partial, details)
    return [] unless details[:theme]
    return [] unless details[:handlers].include?(:liquid)

    conditions = {
      path:        normalize_path(name, prefix),
      partial:     partial || false,
      theme_id: details[:theme]
    }
    EmailTemplate.where(conditions)
  end

  def find_templates(name, prefix, partial, details)
    find_mailers(name, prefix, partial, details).map do |record|
      initialize_template(record, normalize_array(details[:formats]).first)
    end
  end

  protected 

  def template_body(record, format)
    format == "html" ? record.html_body : record.text_body
  end
end
