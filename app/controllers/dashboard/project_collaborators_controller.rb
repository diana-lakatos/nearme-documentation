class Dashboard::TransactableCollaboratorsController < Dashboard::BaseController
  before_filter :find_transactable_type
  before_filter :find_transactable
  before_filter :find_transactable_collaborator, except: [:create]

  def create
    user = User.find_by_email(params[:email])
    @transactable_collaborator = @transactable.transactable_collaborators.create(user: user, approved_at: Time.zone.now)
    render_transactable_collaborator
  end

  def update
    @transactable_collaborator.update_attributes(transactable_collaborator_params)
    render_transactable_collaborator
  end

  def destroy
    @transactable_collaborator.actor = current_user
    @transactable_collaborator.destroy
    render json: { result: 'OK' }
  end

  private

  def render_transactable_collaborator
    html = render_to_string(partial: @transactable_collaborator)
    error = @transactable_collaborator.errors.full_messages.to_sentence
    render json: { html: html, error: error }
  end

  def find_transactable_type
    @transactable_type = TransactableType.find(params[:transactable_type_id])
  end

  def find_transactable
    @transactable = current_user.transactables.find(params[:transactable_id])
  end

  def find_transactable_collaborator
    @transactable_collaborator = @transactable.transactable_collaborators.find(params[:id])
  end

  def transactable_collaborator_params
    params.require(:transactable_collaborator).permit(secured_params.transactable_collaborator)
  end
end
