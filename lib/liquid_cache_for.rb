module Liquid
  class CacheFor < Liquid::Block
    # Examples:
    # cache_for location
    # cache_for location, company
    # cache_for location.listings
    # cache_for location.company.name, location.listings

    def initialize(tag_name, key, tokens)
      super
      @key = key.to_s
    end

    def cache_models
      @key.split(',').map(&:strip)
    end

    def generate_cache_keys(models_hash)
      generated_keys = []
      models_hash.each do |k, v|
        complex_key = k.split('.')
        if complex_key.size > 1
          (complex_key.size - 1).times do |i|
            v = v.send(complex_key[i + 1])
          end
        end
        id_keys = (v.is_a?(Array) ? v.map{|a| a.try(:id).to_s}.join('_') : v.try(:id).to_s)
        date_keys = (v.is_a?(Array) ? v.map{|a| a.try(:updated_at).to_s}.join('_') : v.try(:updated_at).to_s)
        generated_keys << k + id_keys + date_keys
      end
      Digest::MD5.hexdigest(generated_keys.join('-'))
    end

    def transform_complex_key(complex_key)
      complex_key.split('.').first
    end

    def render(context)
      cache_keys = generate_cache_keys(
        Hash[ cache_models.map{|cm| [cm, context[transform_complex_key(cm)]]} ]
      )
      key_to_fetch = PlatformContext.current.instance.id.to_s + PlatformContext.current.instance.context_cache_key.to_s + ::I18n.locale.to_s + cache_keys
      Rails.cache.fetch(key_to_fetch, expires_in: Rails.configuration.default_cache_expires_in) do
        super
      end
    end

    private

    def generate_nested_cache_keys(models_hash)
      generated_keys = []
      models_hash.each do |k, v|
        complex_key = k.split('.')
        if complex_key.size > 1
          (complex_key.size - 1).times do |i|
            v = v.send(complex_key[i + 1])
          end
        end
        id_keys = (v.is_a?(Array) ? v.map{|a| a.try(:id).to_s}.join('_') : v.try(:id).to_s)
        date_keys = (v.is_a?(Array) ? v.map{|a| a.try(:updated_at).to_s}.join('_') : v.try(:updated_at).to_s)
        generated_keys << k + id_keys + date_keys
      end
      generated_keys.join('-')
    end
  end

  Liquid::Template.register_tag('cache_for', CacheFor)
end
