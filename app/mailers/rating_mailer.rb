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
    # that is hack to get the right platform_context based on reservation's listing. I will let Patrik refactor this :-)
    @platform_context = PlatformContext.new(@listing.company.white_label_enabled ? @listing.company.domain.try(:name) : @listing.instance.domains.first.try(:name))

    mail to: @author.email,
         subject: instance_prefix("How was your experience at '#{@listing.name}'?", @platform_context.decorate),
         template_name: "request_#{@kind}_rating",
         platform_context: @platform_context

  end

  if defined? MailView
    class Preview < MailView

      def request_guest_rating
        ::RatingMailer.request_guest_rating(Reservation.last)
      end

      def request_host_rating
        ::RatingMailer.request_host_rating(Reservation.last)
      end
    end
  end

end
