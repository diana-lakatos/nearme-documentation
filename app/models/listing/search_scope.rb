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

    def user_can_add_listing?
      # if this is not white label, user can always add listing
      return true if white_label_company.blank? || !white_label_company.white_label_enabled?
      # if this is white label, only its users should be able to add listing
      user.present? && user.companies.include?(white_label_company)
    end

  end
end
