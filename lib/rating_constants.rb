module RatingConstants
  MAX_QUESTIONS_QUANTITY = 5
  MAX_RATING = 5
  VALID_VALUES = (1..MAX_QUESTIONS_QUANTITY).freeze

  # guest rates host
  HOST = 'host'.freeze
  # guest rates product
  TRANSACTABLE = 'transactable'.freeze
  # host rates guest
  GUEST = 'guest'.freeze
  RATING_SYSTEM_SUBJECTS = [HOST, TRANSACTABLE, GUEST].freeze

end

