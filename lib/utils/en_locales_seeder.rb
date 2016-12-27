module Utils
  class EnLocalesSeeder
    def go!
      count = { existed: 0, created: 0, updated: 0 }

      (Dir.glob(Rails.root.join('config', 'locales', '*.en.yml')) + Dir.glob(Rails.root.join('config', 'locales', 'en.yml'))).each do |yml_filename|
        print_out "File: #{yml_filename}"
        en_locales = YAML.load_file(yml_filename)
        en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])

        print_out "\tUpdating default instances"
        en_locales_hash.each_pair do |key, value|
          t = Translation.find_or_initialize_by(locale: 'en', key: key, instance_id: nil)

          if t.persisted? && t.value != value
            t.value = value
            t.skip_expire_cache = true
            t.save!
            print_out "\t\tTranslation updated: key: #{key}, value: #{t.value} -> #{value}"
            count[:updated] += 1
          elsif t.persisted?
            count[:existed] += 1
          else
            t.value = value
            t.skip_expire_cache = true
            t.save!
            print_out "\t\tTranslation created: key: #{key}, value: #{value}"
            count[:created] += 1
          end
        end
      end
      print_out 'Instance cache update started...'
      Instance.find_each(&:fast_recalculate_cache_key!)

      print_out 'Translation populator report:'
      print_out "  #{count[:existed]} translations already existed."
      print_out "  #{count[:created]} translations were created."
      print_out "  #{count[:updated]} translations were updated."
      print_out ' ********** '
      CacheExpiration.send_expire_command('RebuildTranslations')
    end

    def community_go!
      Instance.where(is_community: true).find_each do |i|
        count = { existed: 0, created: 0, updated: 0 }
        i.set_context!
        puts "Populating community translations for: #{i.name}"
        Dir.glob(Rails.root.join('config', 'community_locales', '*.yml')).each do |yml_filename|
          print_out "File: #{yml_filename}"
          en_locales = YAML.load_file(yml_filename)
          en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])

          en_locales_hash.each_pair do |key, value|
            t = Translation.find_or_initialize_by(locale: 'en', key: key, instance_id: i.id)

            if t.persisted? && t.value != value
              t.value = value
              t.skip_expire_cache = true
              t.save!
              print_out "  Translation updated: key: #{key}, value: #{t.value} -> #{value}"
              count[:updated] += 1
            elsif t.persisted?
              count[:existed] += 1
            else
              t.value = value
              t.skip_expire_cache = true
              t.save!
              print_out "  Translation created: key: #{key}, value: #{value}"
              count[:created] += 1
            end
          end
        end
        print_out 'Instance cache update started...'
        i.fast_recalculate_cache_key!

        print_out 'Translation populator report:'
        print_out "  #{count[:existed]} translations already existed."
        print_out "  #{count[:created]} translations were created."
        print_out "  #{count[:updated]} translations were updated."
      end
    end

    protected

    def print_out(text)
      puts text unless Rails.env.test?
    end

    def convert_hash_to_dot_notation(hash, path = '')
      hash.each_with_object({}) do |(k, v), ret|
        key = path + k

        if v.is_a? Hash
          ret.merge! convert_hash_to_dot_notation(v, key + '.')
        else
          ret[key] = v
        end
      end
    end
  end
end
