class RatingMailer < DesksNearMeMailer

  def request_guest_rating(reservation)
    @subject = reservation.owner
    @author = reservation.listing_creator
    @kind = 'guest'

    request_rating(reservation)
  end

  def request_host_rating(reservation)
    @subject = reservation.listing_creator
    @author = reservation.owner
    @kind = 'host'

    request_rating(reservation)
  end

  private
  def request_rating(reservation)
    @reservation = reservation
    @listing = @reservation.listing
    @location = @listing.location
    @instance = @listing.instance

    mail to: @author.email,
         subject: subject("Rate your #{@kind} at #{@listing.name}"),
         template_name: "request_#{@kind}_rating"
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
