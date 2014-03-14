class ReengagementNoBookingsJob < Job

  def after_initialize(user)
    @user = user
  end

  def perform
    ReengagementMailer.no_bookings(@user).deliver if @user && @user.reservations.empty?
  end
    
end
