module Searching
  class Base
    include CoercionHelpers

    attr_accessor :params

    def initialize(transactable_type, params)
      @transactable_type = transactable_type
      self.params = params
    end

    def params=(params)
      @params = coerce_pagination_params params
    end
  end
end
