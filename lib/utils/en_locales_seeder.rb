module Utils
  class EnLocalesSeeder

    def go!
      Dir.glob(Rails.root.join('config', 'locales', '*.yml')).each do |yml_filename|
        en_locales = YAML.load_file(yml_filename)
        en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])

        en_locales_hash.each_pair do |key, value|
          translation = Translation.where(locale: 'en', key: key, instance_id: nil).first.presence || Translation.new(locale: 'en', key: key, instance_id: nil)
          translation.value = value
          translation.save! if translation.changed?
        end
      end
    end

    protected

    def convert_hash_to_dot_notation(hash, path = '')
      hash.each_with_object({}) do |(k, v), ret|
        key = path + k

        if v.is_a? Hash
          ret.merge! convert_hash_to_dot_notation(v, key + ".")
        else
          ret[key] = v
        end
      end
    end
  end
end
