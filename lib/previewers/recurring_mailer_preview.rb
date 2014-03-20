class RecurringMailerPreview < MailView

  def analytics
    ::RecurringMailer.analytics(Company.first, User.all.select{|u| !u.companies.count.zero?}.first)
  end

  def request_photos
    ::RecurringMailer.request_photos(Listing.first)
  end

  def share
    ::RecurringMailer.share(Listing.first)
  end

end
