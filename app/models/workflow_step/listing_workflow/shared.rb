class WorkflowStep::ListingWorkflow::Shared < WorkflowStep::ListingWorkflow::BaseStep
  def initialize(transactable_id, user_email, user_name, user_id, message)
    @transactable = Transactable.find_by_id(transactable_id)
    @user = User.find_by_id(user_id)
    @message = message
    @user_email = user_email
    @user_name = user_name
  end

  def enquirer
    User.new(email: @user_email, name: @user_email)
  end

  def lister
    @transactable.creator
  end

  # listing:
  #   Transactable
  # email:
  #   string, user email
  # name:
  #   string, user name
  # message:
  #   string, message
  # sharer:
  #   User object (sharing user)
  def data
    { listing: @transactable, email: @user_email, name: @user_name, message: @message, sharer: @user }
  end
end
