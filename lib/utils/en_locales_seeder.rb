module Utils
  class EnLocalesSeeder

    def go!
      count = {existed: 0, created: 0, updated: 0}

      Dir.glob(Rails.root.join('config', 'locales', '*.yml')).each do |yml_filename|
        print_out "File: #{yml_filename}"
        en_locales = YAML.load_file(yml_filename)
        en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])

        en_locales_hash.each_pair do |key, value|
          t = Translation.find_or_initialize_by(locale: 'en', key: key, instance_id: nil)

          if t.persisted? && t.value != value
            t.value = value
            t.save!
            print_out "  Translation updated: key: #{key}, value: #{t.value} -> #{value}"
            count[:updated] += 1
          elsif t.persisted?
            count[:existed] += 1
          else
            t.value = value
            t.save!
            print_out "  Translation created: key: #{key}, value: #{value}"
            count[:created] += 1
          end
        end
      end


      print_out "Translation populator report:"
      print_out "  #{count[:existed]} translations already existed."
      print_out "  #{count[:created]} translations were created."
      print_out "  #{count[:updated]} translations were updated."
    end

    protected

    def print_out(text)
      puts text unless Rails.env.test?
    end

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
