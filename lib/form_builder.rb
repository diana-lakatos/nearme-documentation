# frozen_string_literal: true
class FormBuilder
  def self.form_class_cache
    @form_class_cache ||= FormClassCache.new
  end

  def initialize(configuration:, base_form:, object:)
    @configuration = configuration
    @base_form = base_form
    @object = object
  end

  def build
    fetch_from_form_class_cache do
      @base_form.decorate(@configuration)
    end.new(@object)
  end

  def fetch_from_form_class_cache
    self.class.form_class_cache.fetch(base_form: @base_form, configuration: @configuration) do
      yield
    end
  end

  class FormClassCache
    def initialize
      @cache = {}
    end

    def fetch(base_form:, configuration:)
      base_form = base_form.to_s
      @cache[base_form] ||= {}
      @cache[base_form][Digest::MD5.digest(configuration.to_s)] ||= yield
    end
  end
end
