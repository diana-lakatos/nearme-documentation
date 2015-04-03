class ActionType < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid

  RFQ = 'Request For Quote'
  BOOK = 'Book'
  SUBSCRIBE = 'Subscribe'
  AVAILABLE_NAMES = [RFQ, BOOK, SUBSCRIBE]

  validates_inclusion_of :name, in: AVAILABLE_NAMES
  validates_uniqueness_of :name

end