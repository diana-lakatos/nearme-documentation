# frozen_string_literal: true
class UserProfileDrop < BaseDrop
  # @return [UserProfileDrop]
  attr_accessor :source

  # @!method customizations
  #   @return [Array<CustomizationDrop>] array of customization objects for this user profile (allows extra customization through custom attributes)
  # @!method onboarded_at
  #   Date when the user has been marked as onboarded
  #   @return (see UserProfile#onboarded_at)
  delegate :customizations, :onboarded_at, to: :source

  def initialize(profile)
    @source = profile
  end

  # @return [Hash{String => String}] hash of custom properties for this user profile
  def properties
    @source.properties.to_h
  end
end
