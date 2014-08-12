class DataImporter::SummaryTracker

  attr_accessor :new_entities, :updated_entities

  def initialize
    @new_entities = {}
    @updated_entities = {}
  end

  def increment(entity)
    @entity = entity
    proper_hash[key] ||= 0
    proper_hash[key] += 1
  end

  def decrement(entity)
    @entity = entity
    proper_hash[key] -= 1
  end

  def to_s
    "New entities: #{@new_entites.inspect}\nUpdated entities: #{@updated_entities.inspect}"
  end

  private

  def proper_hash
    @entity.persisted? ? @updated_entities : @new_entities
  end


  def key
    @entity.class.name.underscore.tr(' ','_')
  end


end
