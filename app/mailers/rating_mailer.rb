class RatingMailer < InstanceMailer

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
    @instance = @location.instance

    mail to: @author.email,
         subject: instance_prefix("Rate your #{@kind} at #{@listing.name}", @instance),
         template_name: "request_#{@kind}_rating",
         instance: @instance
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
