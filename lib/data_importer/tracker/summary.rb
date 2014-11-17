class DataImporter::Tracker::Summary < DataImporter::Tracker
  attr_accessor :new_entities, :updated_entities
  def initialize
    @time_start = Time.zone.now.to_f
    @new_entities = { 'user' => 0, 'company'=>  0, 'location' => 0, 'transactable' => 0, 'photo' => 0 }
    @updated_entities = { 'user' => 0, 'company' => 0, 'location' => 0, 'transactable' => 0, 'photo' => 0 }
    @deleted_entities = {}
  end

  def object_created(object, *args)
    increment(object)
  end

  def parsing_finished(hash, *args)
    hash.each { |entity, count| deleted(entity, count) }
  end

  def object_not_saved(object, *args)
    decrement(object)
  end

  def object_valid(object, *args)
    increment(object)
  end

  protected


  def increment(entity)
    @entity = entity
    proper_hash[key] ||= 0
    proper_hash[key] += 1
  end

  def decrement(entity)
    @entity = entity
    proper_hash[key] -= 1
  end

  def deleted(entity, count)
    @deleted_entities[key] = count
  end

  def deleted_decrement(str_key, count)
    @deleted_entities[str_key] -= 1
  end

  private

  def proper_hash
    @entity.persisted? ? @updated_entities : @new_entities
  end


  def key
    @entity.class.name.underscore.tr(' ','_')
  end

end
