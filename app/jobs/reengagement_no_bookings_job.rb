class ReengagementNoBookingsJob < Job

  def initialize(platform_context, user)
    @platform_context = platform_context 
    @user = user
  end

  def perform
    ReengagementMailer.no_bookings(@platform_context, @user).deliver if @user && @user.reservations.empty?
  end
    
end
