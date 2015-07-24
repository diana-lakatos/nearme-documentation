class I18n::Backend::DNMKeyValue < I18n::Backend::KeyValue

  attr_accessor :instance_id

  def initialize(cache, subtrees=true)
    @cache, @subtrees, @store = cache, subtrees, {}
    prepare_store
  end

  def prepare_store
    Translation.uniq.pluck(:instance_id).each do |instance_id|
      _instance_key = instance_key(instance_id)
      @store[_instance_key] = @cache.fetch "locales.#{_instance_key}" do
        populate(instance_id)
        @store[_instance_key]
      end
      touch_cache_timestamp_for(_instance_key, read_cached_at_for(_instance_key)) unless get_cache_timestamp_for(_instance_key)
      # to avoid storing all translations in memory in the future, uncomment line:
      #@store[_instance_key] = nil if instance_id.present?
    end
  end

  def set_instance_id(instance_id)
    self.instance_id = instance_id
    # we don't want to run into memory issues once we support lots of instances
    # @store = @store.slice(instance_key(nil), instance_key(instance_id))
    update_store_for_instance_if_necessary(nil)
    update_store_for_instance_if_necessary(instance_id)
    populate(instance_id)
    populate(nil)
  end

  def update_store_for_instance_if_necessary(instance_id)
    _instance_key = instance_key(instance_id)
    cache_updated_at = read_cached_at_for(_instance_key)
    if @store[_instance_key].nil? || (cache_updated_at && cache_updated_at > get_cache_timestamp_for(_instance_key))
      touch_cache_timestamp_for(_instance_key, cache_updated_at)
      update_store(_instance_key)
    end
  end

  def update_store(_instance_key)
    @store[_instance_key] = @cache.fetch "locales.#{_instance_key}" do
      # setting timestamp to nil here is to protect from case when cache_updated_at is set,
      # but there is no actual data. In that case, we want to populate all transactions
      touch_cache_timestamp_for(_instance_key, nil)
      populate(instance_id)
      @store[_instance_key]
    end
  end

  def populate(_instance_id)
    cache_changed = false
    _instance_key = instance_key(_instance_id)
    translations_scope = (_instance_id.nil? ? Translation.defaults : Translation.for_instance(_instance_id))
    translations_scope = translations_scope.updated_after(get_cache_timestamp_for(_instance_key)) if get_cache_timestamp_for(_instance_key)
    translations_scope.pluck(:locale, :key, :value, :instance_id).each do |translation|
      cache_changed = true
      store_translation(translation)
    end
    if cache_changed
      @cache.write "locales.#{_instance_key}", @store[_instance_key] if get_cache_timestamp_for(_instance_key)
      touch_cache_timestamp_for(_instance_key, write_cached_at_for(_instance_key))
    end
  end

  def store_translation(translation)
    store_translations(translation[0], convert_dot_to_hash(translation[1], translation[2]), {:instance_id => translation[3]})
  end

  def store_translations(locale, data, options = {})
    escape = options.fetch(:escape, true)
    _instance_key = instance_key(options[:instance_id])
    @store[_instance_key] ||= {}
    flatten_translations(locale, data, escape, @subtrees).each do |key, value|
      key = "#{locale}.#{key}"
      case value
        when Hash
          if @subtrees && (old_value = @store[_instance_key][key])
            old_value = ActiveSupport::JSON.decode(old_value)
            value = old_value.deep_symbolize_keys.deep_merge!(value) if old_value.is_a?(Hash)
          end
        when Proc
          raise "Key-value stores cannot handle procs"
      end
      @store[_instance_key][key] = ActiveSupport::JSON.encode(value) unless value.is_a?(Symbol)
    end
  end

  def available_locales
    locales = @store[instance_key(nil)].keys.map { |k| k =~ /\./; $` }
    locales.uniq!
    locales.compact!
    locales.map! { |k| k.to_sym }
    locales
  rescue
    []
  end

  protected

  def lookup(locale, key, scope = [], options = {})
    key = normalize_flat_keys(locale, key, scope, options[:separator])

    value = lookup_for_instance_key locale, key
    value = lookup_for_default_key locale, key if value.blank?

    # Fallback to English
    if value.blank? && locale != :en
      value = lookup_for_en_instance_key(key)
      value = lookup_for_en_default_key(key) if value.blank?
    end

    value.is_a?(Hash) ? value.deep_symbolize_keys : value
  end

  def lookup_for_instance_key(locale, key)
    value = @store[instance_key(instance_id)]["#{locale}.#{key}"]
    sanitize_empty_value value
  rescue
    nil
  end

  def lookup_for_default_key(locale, key)
    value = @store[instance_key(nil)]["#{locale}.#{key}"]
    sanitize_empty_value value
  rescue
    nil
  end

  def lookup_for_en_instance_key(key)
    lookup_for_instance_key(:en, key)
  end

  def lookup_for_en_default_key(key)
    lookup_for_default_key(:en, key)
  end

  # Note that we have to JSON.decode first, as 'empty' value is "\"\"" before that and blank? would return false instead of true
  def sanitize_empty_value(value)
    value.present? ? ActiveSupport::JSON.decode(value) : value
  end

  # transforms key in format "a.b.c.d" and value "x" to hash
  # { :a => { :b => { :c => { :d => "x" } } } }
  def convert_dot_to_hash(string, value = nil, hash = {})
    arr = string.split(".")
    if arr.size == 1
      hash[arr.shift] = value
    else
      el = arr.shift
      hash[el] ||= {}
      hash[el] = convert_dot_to_hash(arr.join('.'), value, hash[el])
    end
    hash
  end

  def touch_cache_timestamp_for(_instance_key, time = Time.zone.now)
    @timestamps ||= {}
    @timestamps[_instance_key] = time
  end

  def get_cache_timestamp_for(_instance_key)
    @timestamps && @timestamps[_instance_key]
  end

  def instance_key(instance_id)
    instance_id.present? ? "#{instance_id}".to_sym : :default
  end

  def write_cached_at_for(_instance_key)
    Time.zone.now.tap { |time| @cache.write "locales.#{_instance_key}.cached_at", time }
  end

  def read_cached_at_for(_instance_key)
    @cache.read "locales.#{_instance_key}.cached_at"
  end

end
