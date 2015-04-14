class RatingSystemsInitializerService

  def initialize(transactable_type)
    @instance = transactable_type.instance
    @transactable_type = transactable_type
  end

  def create_rating_systems!
    [@transactable_type.lessor, @transactable_type.lessee, @transactable_type.bookable_noun].each do |subject|
      rating_system = @instance.rating_systems.where(subject: subject, transactable_type_id: @transactable_type.id).first_or_create
      RatingConstants::VALID_VALUES.each { |value| rating_system.rating_hints.where(value: "#{value}", instance: @instance).first_or_create }
    end
  end

end

