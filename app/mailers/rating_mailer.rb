class RatingMailer < InstanceMailer
  layout 'mailer'

  def request_guest_rating(reservation)
    @subject = reservation.owner
    @author  = reservation.listing_creator
    @kind    = 'guest'

    request_rating(reservation)
  end

  def request_host_rating(reservation)
    @subject = reservation.listing_creator
    @author  = reservation.owner
    @kind    = 'host'

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

    mail to: @author.email,
         subject: instance_prefix("How was your experience at '#{@listing.name}'?", @platform_context.decorate),
         template_name: "request_#{@kind}_rating",
         platform_context: @platform_context

  end

end
