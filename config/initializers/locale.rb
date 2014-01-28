require 'i18n/backend/active_record'

I18n::Backend::ActiveRecord.class_eval do

  attr_accessor :instance_id

  def lookup(locale, key, scope = [], options = {})
    key = normalize_flat_keys(locale, key, scope, options[:separator])
    self.instance_id ||= Instance.default_instance.id
    result = nil
    ActiveRecord::Base.silence do
      result = I18n::Backend::ActiveRecord::Translation.locale(locale).lookup(key).where('instance_id = ? OR instance_id IS NULL', self.instance_id).order('instance_id ASC').all
    end

    if result.empty?
      nil
    elsif result.first.key == key
      result.first.value
    else
      chop_range = (key.size + I18n::Backend::ActiveRecord::FLATTEN_SEPARATOR.size)..-1
      result = result.inject({}) do |hash, r|
        hash[r.key.slice(chop_range)] = r.value
        hash
      end
      result.deep_symbolize_keys
    end

  rescue ::ActiveRecord::StatementInvalid
    # is the translations table missing?
    nil
  end
end

I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n::Backend::Simple.new)
