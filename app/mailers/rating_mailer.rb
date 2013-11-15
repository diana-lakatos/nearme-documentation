class RatingMailer < InstanceMailer
  layout 'mailer'

  def request_guest_rating(reservation)
    @who_is_rating      = 'host'
    @user  = reservation.listing_creator

    @who_is_rated       = 'guest'
    @subject = reservation.owner

    @subject = "How was your experience hosting #{reservation.owner.first_name}?"
    request_rating(reservation)
  end

  def request_host_rating(reservation)
    @who_is_rating    = 'guest'
    @user  = reservation.owner

    @who_is_rated     = 'host'
    @subject = reservation.listing_creator

    @subject = "How was your experience at '#{reservation.listing.name}'?"
    request_rating(reservation)
  end

  private
  def request_rating(reservation)
    @reservation = reservation
    @listing = @reservation.listing
    @location = @listing.location
    domain = if @listing.company.white_label_enabled?
               @listing.company.domain
             else
               @listing.instance.domains.first
             end
    @platform_context = PlatformContext.new(domain.try(:name))

    mail to: @user.email,
         subject: instance_prefix(@subject, @platform_context.decorate),
         template_name: "request_rating_of_#{@who_is_rated}_from_#{@who_is_rating}",
         platform_context: @platform_context

  end

end
