class ReengagementMailer < InstanceMailer
  layout 'mailer' 

  def no_bookings(user)
    @user = user
    @listing = Listing.first

    if should_be_sent?
      mail to: @user.email, 
             subject: instance_prefix("Check out these new #{instance_bookable_noun.pluralize} in your area!")
    else
      Rails.logger.info "ReengagementMailer no_bookings has not been sent to #{@user.id} #{@user.name} because we don't know what to suggest"
    end
  end

  def one_booking(reservation)
    @reservation = reservation
    @listing = @reservation.listing
    @user = @reservation.owner

    if should_be_sent?
      mail to: @user.email, 
             subject: instance_prefix("Check out these new #{instance_bookable_noun.pluralize} in your area!")
    else
      Rails.logger.info "ReengagementMailer one_booking has not been sent to #{@user.id} #{@user.name} because we don't know what to suggest"
    end
  end

  def mail_type
    DNM::MAIL_TYPES::NON_TRANSACTIONAL
  end

  private

  def should_be_sent?
    @user.listings_in_near.size > 0
  end

end
