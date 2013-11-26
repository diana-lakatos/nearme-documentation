class ReengagementMailer < InstanceMailer
  layout 'mailer' 

  def no_bookings(platform_context, user)
    @user = user
    @platform_context = platform_context
    @platform_context_decorator = @platform_context.decorate
    @listing = Listing.first

    mail to: @user.email, 
           subject: instance_prefix("Check out these new spaces in your area!", @platform_context_decorator),
           platform_context: @platform_context
  end

  def one_booking(platform_context, reservation)
    @reservation = reservation
    @listing = @reservation.listing
    @user = @reservation.owner
    @platform_context = platform_context
    @platform_context_decorator = @platform_context.decorate

    mail to: @user.email, 
           subject: instance_prefix("Check out these new spaces in your area!", @platform_context_decorator),
           platform_context: @platform_context
  end

  def mail_type
    DNM::MAIL_TYPES::NON_TRANSACTIONAL
  end

end
