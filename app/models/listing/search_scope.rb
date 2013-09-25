class Listing
  class SearchScope

    attr_accessor :white_label_company, :user

    def initialize(options = {})
      @white_label_company = options[:white_label_company]
      @user = options[:user]
    end

    def locations
      @locations ||= begin
        if white_label_company.try(:white_label_enabled?)
          Location.where(:"locations.company_id" => white_label_company.id)
        else
          Location.joins(:company).where(companies: {listings_public: true})
        end
      end
    end

  end
end
