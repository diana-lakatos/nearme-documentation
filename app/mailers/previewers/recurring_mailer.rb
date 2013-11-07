if defined? MailView
  class Previewers::RecurringMailer < MailView

    def analytics
      ::RecurringMailer.analytics(Company.first, User.all.select{|u| !u.companies.count.zero?}.first)
    end

    def request_photos
      ::RecurringMailer.request_photos(Listing.first)
    end

    def share
      ::RecurringMailer.share(Reservation.first.listing)
    end

  end
end
