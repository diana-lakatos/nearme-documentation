module Controller
  module Scopes

    def scoped_locations
      @scoped_locations ||= LocationPolicy.scope(@current_white_label_company)
    end
    
  end
end
