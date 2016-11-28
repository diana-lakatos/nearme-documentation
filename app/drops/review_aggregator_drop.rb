# frozen_string_literal: true
class ReviewAggregatorDrop < BaseDrop

  # @!method user
  #   @return [UserDrop] user for which the numbers are counted
  # @!method about_seller
  #   @return [Integer] number of reviews about user for role seller
  # @!method about_buyer
  #   @return [Integer] number of reviews about user for buyer role
  # @!method left_by_seller
  #   @return [Integer] number of reviews left by user as seller
  # @!method left_by_buyer
  #   @return [Integer] number of reviews left by user as buyer
  # @!method left_by_buyer_about_host
  #   @return [Integer] number of reviews left by user about another user
  # @!method left_by_buyer_about_transactable
  #   @return [Integer] number of reviews left by user about a transactable
  delegate :user, :about_seller, :about_buyer, :left_by_seller, :left_by_buyer,
           :left_by_buyer_about_host, :left_by_buyer_about_transactable,
           to: :source

end
