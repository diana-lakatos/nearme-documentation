module RatingConstants
  MAX_RATING = 5
  VALID_VALUES = (1..MAX_RATING).freeze

  # guest rates host
  HOST = 'host'.freeze
  # guest rates product
  TRANSACTABLE = 'transactable'.freeze
  # host rates guest
  GUEST = 'guest'.freeze
  RATING_SYSTEM_SUBJECTS = [HOST, TRANSACTABLE, GUEST].freeze

end

