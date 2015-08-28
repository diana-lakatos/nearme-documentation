module RatingConstants
  MAX_QUESTIONS_QUANTITY = 5
  MAX_RATING = 5
  VALID_VALUES = (1..MAX_QUESTIONS_QUANTITY).freeze

  HOST = 'host'.freeze
  TRANSACTABLE = 'transactable'.freeze
  GUEST = 'guest'.freeze
  RATING_SYSTEM_SUBJECTS = [HOST, TRANSACTABLE, GUEST].freeze

end

