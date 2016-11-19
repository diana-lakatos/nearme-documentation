# frozen_string_literal: true
class ReviewAggregatorDrop < BaseDrop
  # id
  #   unique id of the user
  # user
  #   user for which the numbers are counted
  # about_seller
  #   number of reviews about user for role seller
  # about_buyer
  #   number of reviews about user for buyer role
  # left_by_seller
  #   number of reviews left by user as seller
  # left_by_buyer
  #   number of reviews left by user as buyer
  # left_by_buyer_about_host
  #   number of reviews left by user about another user
  # left_by_buyer_about_transactable
  #   number of reviews left by user about a transactable
  # total
  #   sum of all reviews related to user
  delegate :user, :about_seller, :about_buyer, :left_by_seller, :left_by_buyer,
           :left_by_buyer_about_host, :left_by_buyer_about_transactable,
           to: :source
end
