# frozen_string_literal: true
class UserProfileDrop < BaseDrop
  # @return [UserProfileDrop]
  attr_accessor :source

  # @!method customizations
  #   @return [Array<CustomizationDrop>] array of customization objects for this user profile (allows extra customization through custom attributes)
  # @!method onboarded_at
  #   @return [DateTime] Date when the user has been marked as onboarded
  delegate :customizations, :onboarded_at, to: :source

  def initialize(profile)
    @source = profile
  end

  # @return [Hash{String => String}] hash of custom properties for this user profile
  def properties
    @source.properties.to_h
  end

  # @return [Hash{String => Array}] hash of customizations grouped by custom model type name
  def customizations_by_type
    @customizations_by_type ||= @source.customizations.each_with_object({}) do |customization, results|
      results[customization.custom_model_type.name] ||= []
      results[customization.custom_model_type.name] << customization.properties
      results
    end
  end
end
