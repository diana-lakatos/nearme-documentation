class ReengagementNoBookingsJob < Job
  def after_initialize(user_id)
    @user_id = user_id
  end

  def perform
    @user = User.find_by_id(@user_id)
    if @user
      WorkflowStepJob.perform(WorkflowStep::SignUpWorkflow::NoReservations, @user.id) if @user.orders.empty? && @user.listings_in_near.size > 0
    end
  end
end
