class Listing
  class SearchScope

    attr_accessor :white_label_company, :user

    def initialize(options = {})
      @white_label_company = options[:white_label_company]
      @user = options[:user]
    end

    def locations
      if white_label_company.try(:white_label_enabled?)
        white_label_company.locations
      else
        Location.scoped
      end
    end

  end
end
