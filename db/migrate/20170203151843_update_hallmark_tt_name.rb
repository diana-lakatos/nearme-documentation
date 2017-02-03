class UpdateHallmarkTtName < ActiveRecord::Migration
  def up
    i = Instance.find_by(id: 5011)
    return true if i.nil?
    i.set_context!
    Translation.where('value like ?', '%DIY%').where(instance_id: 5011).each do |t|
      new_value = t.value.gsub('DIY', 'Share')
      puts "Updating #{t.value} to #{new_value}"
      t.update_attribute(:value, new_value)
    end

    t = Translation.where(locale: :en, key: 'featured_projects', instance_id: 5011).first_or_initialize
    t.value = 'Latest from the Community'
    t.save!

    Dir.glob(Rails.root.join('marketplaces', 'hallmark', 'translations', '*.yml')).each do |yml_filename|
      en_locales = YAML.load_file(yml_filename)
      en_locales_hash = convert_hash_to_dot_notation(en_locales['en'])

      en_locales_hash.each_pair do |key, value|
        next if key.include?('transactable_type.diy')
        next if Translation.where(key: key, instance_id: 5011).exists?
        value = value.gsub('DIY', 'Share')
        puts "Creating translation for: #{key} -> #{value}"
        Translation.create!(locale: 'en', key: key, instance_id: 5011, value: value)
      end
    end

    Page.find_each do |p|
      p.update_attribute(:html_content, p.html_content.gsub('DIY', 'Share'))
    end
    InstanceView.find_each do |iv|
      iv.update_attribute(:body, iv.body.gsub('DIY', 'Share'))
    end
    Translation.where(key: 'project', instance_id: 5011).first&.update_attribute(:value, 'Share')
    tt = TransactableType.where(name: 'DIY').first
    return true if tt.nil?
    puts "Updating TT for Hallmark"
    tt.name = 'Share'
    tt.slug = 'share'
    tt.bookable_noun = 'Share'
    tt.save!
  end

  def down
  end

  protected


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
