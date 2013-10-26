class DbViewResolver < ActionView::Resolver

  def find_templates(name, prefix, partial, details) 
    raise NotImplementedError.new('You must implement find_templates method!')
  end

  protected

  def normalize_path(name, prefix)
    prefix.present? ? "#{prefix}/#{name}" : name
  end

  def normalize_array(array)
    array.map(&:to_s)
  end

  def initialize_template(record, format)
    source = template_body(record, format)
    identifier = "#{record.class.name} - #{record.id} - #{record.path.inspect}"
    handler = ActionView::Template.registered_template_handler(record.handler)

    details = {
      format:       Mime[format],
      update_at:    record.updated_at,
      virtual_path: virtual_path(record.path, record.partial),
      model:        record
    }

    ActionView::Template.new(source, identifier, handler, details)
  end

  def template_body(record, format)
    record.body
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

