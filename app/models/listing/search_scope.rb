class Listing
  class SearchScope

    attr_accessor :white_label_company, :user

    def initialize(options = {})
      @white_label_company = options[:white_label_company]
      @user = options[:user]
    end

    def locations
      if white_label_company.present?
        white_label_company.locations
      else
        Location.scoped
      end
    end

    def user_can_add_listing?
      # if this is not white label, user can always add listing
      # if this is white label, only its users should be able to add listing
      white_label_company.blank? || (user.present? && user.companies.include?(white_label_company))
    end

  end
end
