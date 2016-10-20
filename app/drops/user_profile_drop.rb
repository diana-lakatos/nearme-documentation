class UserProfileDrop < BaseDrop
  attr_accessor :source

  delegate :customizations, :onboarded_at, to: :source

  def initialize(profile)
    @source = profile
  end

  def properties
    properties.to_hash
  end
end
