require 'ansi/progressbar'

namespace :elastic do
  namespace :reindex do
    desc 'Re-creates and fills Transactable index'
    task all_transactables: [:environment] do
      # DESTROYS THE INDEX AND REBUILD IT FROM SCRATCH FOR ALL INSTANCES
      Instance.find_each do |instance|
        instance.set_context!
        puts "Rebuiliding index #{Transactable.index_name}"
        Transactable.__elasticsearch__.create_index! force: true
        update_index_for Transactable
      end
    end

    desc 'Re-creates and fills Transactable index for certain Instance'
    task :transactables_for_instance, [:instance_id] => :environment do |_t, args|
      # DESTROYS THE INDEX AND REBUILD IT FROM SCRATCH FOR PROVIDED INSTANCE
      instance_id = args[:instance_id]
      return puts "instance_id is blank" if instance_id.blank?
      instance = Instance.find(instance_id)
      instance.set_context!
      puts "Rebuiliding index #{Transactable.index_name}"
      Transactable.__elasticsearch__.create_index! force: true
      update_index_for Transactable
    end

    desc 'Re-creates and fills User index'
    task all_users: [:environment] do
      # DO NOT RUN THIS MANUALLY -> DESTROYS THE INDEX. PlatformContext does not matter
      Instance.find_each do |instance|
        instance.set_context!
        puts "Rebuiliding index #{User.index_name}"
        User.__elasticsearch__.create_index! force: true
        update_index_for(User)
      end
    end

    desc 'Re-creates and fills User index for certain Instance'
    task :users_for_instance, [:instance_id] => :environment do |_t, args|
      # DESTROYS THE INDEX AND REBUILD IT FROM SCRATCH FOR PROVIDED INSTANCE
      instance_id = args[:instance_id]
      return puts "instance_id is blank" if instance_id.blank?
      instance = Instance.find(instance_id)
      instance.set_context!
      puts "Rebuiliding index #{User.index_name}"
      User.__elasticsearch__.create_index! force: true
      update_index_for User
    end

    desc 'Re-creates and fills all indexes'
    task all_indexes: [:environment] do
      # DO NOT RUN THIS MANUALLY -> DESTROYS THE INDEX. PlatformContext does not matter
      Instance.find_each do |instance|
        instance.set_context!
        puts "Rebuiliding index #{Transactable.index_name}"
        Transactable.__elasticsearch__.create_index! force: true
        update_index_for(Transactable)
        puts "Rebuiliding index #{User.index_name}"
        User.__elasticsearch__.create_index! force: true
        update_index_for(User)
      end
    end

    desc 'Re-creates and fills all individual indexes'
    task all_individual_indexes: [:environment] do
      # DO NOT RUN THIS MANUALLY -> DESTROYS THE INDEX. PlatformContext does not matter
      Instance.find_each do |instance|
        instance.set_context!
        PlatformContext.current.instance.search_settings['use_individual_index'] = 'true'
        puts "Rebuiliding index #{Transactable.index_name}"
        Transactable.__elasticsearch__.create_index! force: true
        update_index_for(Transactable)
        puts "Rebuiliding index #{User.index_name}"
        User.__elasticsearch__.create_index! force: true
        update_index_for(User)
      end
    end

    desc 'Re-creates and fills all individual indexes for instance'
    task :all_individual_indexes_for_instance, [:instance_id] => :environment do |_t, args|
      # DO NOT RUN THIS MANUALLY -> DESTROYS THE INDEX. PlatformContext does not matter
      instance_id = args[:instance_id]
      return puts "instance_id is blank" if instance_id.blank?
      instance = Instance.find(instance_id)
      instance.set_context!
      PlatformContext.current.instance.search_settings['use_individual_index'] = 'true'
      puts "Rebuiliding index #{Transactable.index_name}"
      Transactable.__elasticsearch__.create_index! force: true
      update_index_for(Transactable)
      puts "Rebuiliding index #{User.index_name}"
      User.__elasticsearch__.create_index! force: true
      update_index_for(User)
    end
  end

  namespace :update do

    desc 'Updates indexes and documents'
    task all_indexes: :environment do
      Instance.find_each do |instance|
        instance.set_context!
        puts "Reindexing instance --====#{instance.name} - #{instance.id}====--"
        puts "Objects to index: #{Transactable.searchable.count}"
        update_mappings_for Transactable
        update_mappings_for User
        update_index_for Transactable
        update_index_for User
      end
    end

    desc 'Updates mappings'
    task all_mappings: :environment do
      Instance.find_each do |instance|
        instance.set_context!
        puts "Updating mappings of instance #{instance.name} - #{instance.id}"
        update_mappings_for Transactable
        update_mappings_for User
      end
    end

    desc 'Updates mappings for instance'
    task :mappings_for_instance, [:instance_id] => :environment do |_t, args|
      instance_id = args[:instance_id]
      return puts "instance_id is blank" if instance_id.blank?
      instance = Instance.find(instance_id)
      instance.set_context!
      puts "Updating mappings of instance #{instance.name} - #{instance.id}"
      update_mappings_for Transactable
      update_mappings_for User
    end
  end

  def update_mappings_for(class_name)
    begin
      if class_name.__elasticsearch__.client.indices.exists? index: class_name.index_name
        puts "Updating index #{class_name.index_name}"
        puts class_name.__elasticsearch__.client.indices.put_mapping index: class_name.index_name, type: "#{class_name.to_s.downcase}", body: class_name.mappings
      else
        puts "Index #{class_name.index_name} does not exists"
      end
    rescue Exception => e
      puts "Can't update index: #{e}"
    end
  end

  def update_index_for(class_name)
    instance = PlatformContext.current.instance
    puts "Reindexing instance --===#{instance.name} - #{instance.id}===--"
    all_objects = class_name.searchable.count
    puts "Objects to index: #{all_objects}"
    pbar = ANSI::Progressbar.new(class_name.to_s, all_objects)
    pbar.__send__ :show if pbar
    class_name.searchable.import batch_size: 50 do |response|
      if pbar
        pbar.inc response['items'].size
      else
        puts "Objects left: #{ all_objects -= response["items"].size }"
      end
    end
    pbar.finish
  end
end
