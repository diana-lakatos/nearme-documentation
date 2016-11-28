require 'ansi/progressbar'

namespace :elastic do

  desc 'Create aliases for all indices'
  task create_aliases: [:environment] do
    es_indices = Transactable.__elasticsearch__.client.indices
    indices = es_indices.stats["indices"]
    indices.each_key do |index|
      unless es_indices.exists_alias index: index, name: "#{index}-alias"
        Transactable.__elasticsearch__.client.indices.put_alias index: index, name: "#{index}-alias"
        puts "Created alias for #{index}"
      else
        puts "Alias for #{index} exists"
      end
    end
  end

  namespace :indices do

    task create: [:environment] do
      Instance.find_each do |instance|
        instance.set_context!
        Instance::CLASSES_WITH_ES_INDEX.each do |klass|
          puts "For instance --===#{instance.name} - #{instance.id}===-- Creating index #{klass.base_index_name}"
          klass.indexer_helper.create_base_index
        end
      end
    end

    namespace :rebuild do

      desc 'Re-creates and fills Transactable index'
      task transactables: [:environment] do
        Instance.find_each do |instance|
          instance.set_context!
          rebuild_index_for Transactable
        end
      end

      desc 'Re-creates and fills Transactable index for certain Instance'
      task :transactables_for_instance, [:instance_id] => :environment do |_t, args|
        instance_id = args[:instance_id]
        return puts "instance_id is blank" if instance_id.blank?
        instance = Instance.find(instance_id)
        instance.set_context!
        rebuild_index_for Transactable
      end

      desc 'Re-creates and fills User index'
      task users: [:environment] do
        Instance.find_each do |instance|
          instance.set_context!
          rebuild_index_for User
        end
      end

      desc 'Re-creates and fills User index for certain Instance'
      task :users_for_instance, [:instance_id] => :environment do |_t, args|
        instance_id = args[:instance_id]
        return puts "instance_id is blank" if instance_id.blank?
        instance = Instance.find(instance_id)
        instance.set_context!
        rebuild_index_for User
      end

      desc 'Re-creates and fills all indexes'
      task all: [:environment] do
        Instance.find_each do |instance|
          instance.set_context!
          rebuild_index_for Instance::CLASSES_WITH_ES_INDEX
        end
      end

      desc 'Re-creates and fills all indexes for certain Instance'
      task :all_for_instance, [:instance_id] => :environment do |_t, args|
        instance_id = args[:instance_id]
        return puts "instance_id is blank" if instance_id.blank?
        instance = Instance.find(instance_id)
        instance.set_context!
        rebuild_index_for Instance::CLASSES_WITH_ES_INDEX
      end
    end

    namespace :refresh do

      desc 'Creates new index and copy content of old index with reindex method'
      task all: :environment do
        Instance.find_each do |instance|
          instance.set_context!
          refresh_index_for Instance::CLASSES_WITH_ES_INDEX
        end
      end

      desc 'Creates new index and copy content of old index with reindex method for instance'
      task :all_for_instance, [:instance_id] => :environment do |_t, args|
        instance_id = args[:instance_id]
        return puts "instance_id is blank" if instance_id.blank?
        instance = Instance.find(instance_id)
        instance.set_context!
        refresh_index_for Instance::CLASSES_WITH_ES_INDEX
      end

    end
  end

  def rebuild_index_for(klasses)
    instance = PlatformContext.current.instance
    Array(klasses).each do |klass|
      puts "For instance --===#{instance.name} - #{instance.id}===-- Rebuilding index #{klass.base_index_name}"
      all_objects = klass.searchable.count
      puts "Objects to index: #{all_objects}"
      klass.indexer_helper.with_alias do |new_index_name, old_index_name|
        klass.__elasticsearch__.index_name = new_index_name
        pbar = ANSI::Progressbar.new(klass.to_s, all_objects)
        pbar.__send__ :show if pbar
        klass.searchable.import batch_size: 50 do |response|
          if pbar
            pbar.inc response['items'].size
          else
            puts "Objects left: #{ all_objects -= response["items"].size }"
          end
        end
        pbar.finish
      end
    end
  end

  def refresh_index_for(klasses)
    instance = PlatformContext.current.instance
    Array(klasses).each do |klass|
      klass.indexer_helper.with_alias do |new_index_name, old_index_name|
        puts "For instance --===#{instance.name} - #{instance.id}===-- Moving documents from #{old_index_name} to #{new_index_name}"
        klass.__elasticsearch__.client.indices.put_settings index: old_index_name, body: { index: { "blocks.write": true } }
        klass.__elasticsearch__.client.reindex body: { source: { index: old_index_name }, dest: { index: new_index_name } }
      end
    end
  end
end
