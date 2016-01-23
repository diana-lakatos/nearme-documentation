module Utils
  class EnLocalesSeeder

    def go!
      count = {existed: 0, created: 0, updated: 0}

      (Dir.glob(Rails.root.join('config', 'locales', '*.en.yml')) + Dir.glob(Rails.root.join('config', 'locales', 'en.yml'))).each do |yml_filename|
        print_out "File: #{yml_filename}"
        en_locales = YAML.load_file(yml_filename)
        en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])

        print_out "\tUpdating default instances"
        en_locales_hash.each_pair do |key, value|
          t = Translation.find_or_initialize_by(locale: 'en', key: key, instance_id: nil)

          if t.persisted? && t.value != value
            t.value = value
            t.save!
            print_out "\t\tTranslation updated: key: #{key}, value: #{t.value} -> #{value}"
            count[:updated] += 1
          elsif t.persisted?
            count[:existed] += 1
          else
            t.value = value
            t.save!
            print_out "\t\tTranslation created: key: #{key}, value: #{value}"
            count[:created] += 1
          end
        end
        Instance.find_each do |i|
          i.set_context!
          next if i.primary_locale.to_sym == :en
          puts "\tInstance #{i.name} has primary locale #{i.primary_locale} different than english, making sure defaults are populated"
          en_locales_hash.each_pair do |key, value|
            t = Translation.find_or_initialize_by(locale: i.primary_locale, key: key, instance_id: i.id)
            if t.new_record?
              t.value = value
              t.save!
              print_out "\t\tTranslation created: key: #{key}, value: #{value}"
            end
          end
          Translation.where(locale: :en, instance_id: i.id).find_each do |t|
            translation = Translation.find_or_initialize_by(locale: i.primary_locale, key: t.key, instance_id: i.id)
            if translation.new_record?
              translation.value = t.value
              translation.save!
              print_out "\t\tEnglish version for #{t.key} exists but not for primary, creating"
            end
          end
        end
      end
      print_out "Instance cache update started..."
      Instance.find_each{|i| i.fast_recalculate_cache_key!}

      print_out "Translation populator report:"
      print_out "  #{count[:existed]} translations already existed."
      print_out "  #{count[:created]} translations were created."
      print_out "  #{count[:updated]} translations were updated."
      print_out " ********** "
      community_go!
    end

    def community_go!
      Instance.where(is_community: true).find_each do |i|
        count = {existed: 0, created: 0, updated: 0}
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
        print_out "Instance cache update started..."
        i.fast_recalculate_cache_key!

        print_out "Translation populator report:"
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
          ret.merge! convert_hash_to_dot_notation(v, key + ".")
        else
          ret[key] = v
        end
      end
    end
  end
end
