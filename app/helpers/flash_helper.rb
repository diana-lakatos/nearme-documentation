module FlashHelper


  def get_flash_info_hash(key)
    parts  = key.to_s.split(' ')
    icon_class = get_icon_class(parts[0])
    color_class = get_color_class(parts[1])
    {:icon => icon_class, :color => color_class} if icon_class.present? && color_class.present?
  end

  def get_icon_class(key)
    case key
    when 'create' then "ico-check"
    when 'delete' then "ico-close"
    when 'warning' then "ico-warning"
    end
  end

  def get_color_class(key)
    key if ['green', 'blue', 'orange', 'red'].include?(key)
  end

end
