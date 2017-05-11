ENV['RAILS_ENV'] ||= 'development'

namespace :elasticsearch do
  desc 'create index for instance'
  task :create_index, [:instance_id] => :environment do |_t, args|
    Instance.find(args[:instance_id]).tap do |instance|
      instance.set_context!

      # setup
      engine = Elastic::Engine.new
      builder = Elastic.default_index_name_builder(instance)
      index_type = Elastic::IndexTypes::MultipleModel.new(sources: find_sources)

      # ensure index exists
      unless engine.index_exists? builder.alias_name
        engine.create_index Elastic::IndexZero.new(type: index_type, version: 0, builder: builder)
      end

      # find current index
      current_index = engine.find_index(builder.alias_name)

      # prepare index
      index = Elastic::Index.new(type: index_type, version: current_index.version.next, builder: builder)

      # create new index
      engine.create_index index

      # import data to new index
      engine.import index

      # change alias to new index
      engine.switch_alias from: current_index, to: index
    end
  end

  def find_sources
    [].tap do |items|
      items << User
      items << Transactable if TransactableType.searchable.any?
    end
  end
end
