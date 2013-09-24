require 'singleton'

class EmailResolver < ActionView::Resolver
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

  protected

  def find_templates(name, prefix, partial, details)
    find_mailers(name, prefix, partial, details).map do |record|
      initialize_template(record, normalize_array(details[:formats]).first)
    end
  end

  def normalize_path(name, prefix)
    prefix.present? ? "#{prefix}/#{name}" : name
  end

  def normalize_array(array)
    array.map(&:to_s)
  end

  def initialize_template(record, format)
    source = format == "html" ? record.html_body : record.text_body
    identifier = "EmailTemplate - #{record.id} - #{record.path.inspect}"
    handler = ActionView::Template.registered_template_handler(record.handler)

    details = {
      format:       Mime[format],
      update_at:    record.updated_at,
      virtual_path: virtual_path(record.path, record.partial),
      model:        record
    }

    ActionView::Template.new(source, identifier, handler, details)
  end

  def virtual_path(path, partial)
    return path unless partial
    if index = path.rindex('/')
      path.insert(index + 1, '_')
    else
      "_#{path}"
    end
  end
end
