# frozen_string_literal: true
require 'singleton'

class InstanceViewResolver < DbViewResolver
  include Singleton

  def find_templates(name, prefix, partial, details, _outside_app_allowed = false)
    ActiveRecord::Base.logger.silence do
      # FIXME: we want to be able to use partials in xml pages
      # the format abstraction is hidden there, so this is a hack
      # to disregard it
      details[:formats] << :html if details[:formats].include?(:xml)
      views = _find_templates name, prefix, partial, details

      # Fallback to primary
      if views.count < 1 && PlatformContext.current.try(:instance).try(:primary_locale).present? && normalize_array(details[:locale]).first != PlatformContext.current.instance.primary_locale
        # if we just modify details, we will be using primary locale not only for this path, but also for all others
        views = _find_templates name, prefix, partial, details.dup.tap { |d| d[:locale] = [PlatformContext.current.instance.primary_locale] }
      end

      # Fallback to not custom theme
      if views.count < 1 && details[:custom_theme_id].present?
        views = find_templates(name, prefix, partial, details.except(:custom_theme_id))
      end
      views
    end
  end

  def get_body(name, prefix, partial, details)
    get_templates(name, prefix, partial, details).first.try(:body)
  end

  def expire_cache_for_path(path, instance_id = nil)
    return if path.blank? || instance_id.nil? && PlatformContext.current.nil?
    cache = @cache.instance_variable_get('@data')
    instance_id ||= PlatformContext.current.instance.id

    cache.keys.compact.select { |k| k.instance_id == instance_id }.each do |instance_key|
      components = path.split('/')
      components = [instance_key, components.pop, components.join('/')]
      length = components.length
      tmp_cache = cache
      (0...length).each do |i|
        if i == length - 1
          tmp_cache.send('delete', components[length - 1])
        else
          tmp_cache = tmp_cache.send('[]', components[i])
          break if tmp_cache.keys.empty?
        end
      end
    end
  end

  private

  def _find_templates(name, prefix, partial, details)
    conditions = {
      path: normalize_path(name, prefix),
      format: normalize_array(details[:formats]),
      handler: normalize_array(details[:handlers]),
      partial: partial || false,
      custom_theme_id: details[:custom_theme_id]
    }
    get_templates(conditions, details).map do |record|
      initialize_template(record, record.format)
    end
  end

  def get_templates(conditions, details)
    locale = normalize_array(details[:locale]).first
    transactable_type_id = details[:transactable_type_id]

    scope = ::InstanceView.published
                          .for_instance_id(details[:instance_id])
                          .for_locale(locale)
                          .where(conditions).order('instance_id')
    scope = scope.for_transactable_type_id(transactable_type_id) if transactable_type_id.present?
    scope
  end
end
