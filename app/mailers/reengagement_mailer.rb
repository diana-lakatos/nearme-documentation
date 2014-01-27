class ReengagementMailer < InstanceMailer
  layout 'mailer' 

  def no_bookings(platform_context, user)
    @user = user
    @platform_context = platform_context
    @platform_context_decorator = @platform_context.decorate
    @listing = Listing.first

    if should_be_sent?
      mail to: @user.email, 
             subject: instance_prefix("Check out these new #{@platform_context_decorator.bookable_noun.pluralize} in your area!", @platform_context_decorator),
             platform_context: @platform_context
    else
      Rails.logger.info "ReengagementMailer no_bookings has not been sent to #{@user.id} #{@user.name} because we don't know what to suggest"
    end
  end

  def one_booking(platform_context, reservation)
    @reservation = reservation
    @listing = @reservation.listing
    @user = @reservation.owner
    @platform_context = platform_context
    @platform_context_decorator = @platform_context.decorate

    if should_be_sent?
      mail to: @user.email, 
             subject: instance_prefix("Check out these new #{@platform_context_decorator.bookable_noun.pluralize} in your area!", @platform_context_decorator),
             platform_context: @platform_context
    else
      Rails.logger.info "ReengagementMailer one_booking has not been sent to #{@user.id} #{@user.name} because we don't know what to suggest"
    end
  end

  def mail_type
    DNM::MAIL_TYPES::NON_TRANSACTIONAL
  end

  private

  def should_be_sent?
    @user.listings_in_near(@platform_context).size > 0
  end

end
