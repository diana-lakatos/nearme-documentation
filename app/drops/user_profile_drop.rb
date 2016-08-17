class UserProfileDrop < BaseDrop

  attr_accessor :source

  delegate :customizations, to: :source

  def initialize(profile)
    @source = profile
  end

  def properties
    properties.to_hash
  end

end
