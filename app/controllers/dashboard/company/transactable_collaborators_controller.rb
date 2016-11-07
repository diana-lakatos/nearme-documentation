class Dashboard::Company::TransactableCollaboratorsController < Dashboard::BaseController
  before_action :find_transactable
  before_action :find_transactable_type
  before_action :find_transactable_collaborator, except: [:create, :create_bulk]

  def create
    @transactable_collaborator = @transactable.transactable_collaborators.create(transactable_collaborator_params) do |tc|
      tc.approved_by_owner_at = Time.zone.now
    end
    render_transactable_collaborator
  end

  def create_bulk
    @users = User.where(id: params[:transactable_collaborator][:user_ids])
    users_attrs = @users.map { |u| { user_id: u.id, approved_by_owner_at: Time.zone.now } }
    @transactable_collaborators = @transactable.transactable_collaborators.create!(users_attrs)

    render json: { html: render_to_string(partial: 'create_bulk') }, status: 200
  end

  def update
    @transactable_collaborator.update_attributes(transactable_collaborator_params)
    render_transactable_collaborator
  end

  def destroy
    respond_to do |format|
      if @transactable.pending? || !@transactable.line_item_orders.where.not(confirmed_at: nil).where(user: @transactable_collaborator.user).exists?
        @transactable_collaborator.actor = current_user
        @transactable_collaborator.destroy
        format.html do
          flash[:notice] = I18n.t('transactable_collaborator.collaboration_cancelled')
          redirect_to dashboard_company_transactable_type_transactables_path(@transactable_type)
        end
        format.json { render json: { result: 'OK' } }
      else
        format.html do
          flash[:error] = I18n.t('transactable_collaborator.cant_remove_collaborator')
          redirect_to dashboard_company_transactable_type_transactables_path(@transactable_type)
        end
        format.json { render json: { result: I18n.t('transactable_collaborator.cant_remove_collaborator') } }
      end
    end
  end

  private

  def render_transactable_collaborator
    html = render_to_string(partial: @transactable_collaborator)
    error = @transactable_collaborator.errors.full_messages.to_sentence
    render json: { html: html, error: error }, status: error.present? ? 400 : 200
  end

  def find_transactable_type
    @transactable_type = @transactable.transactable_type
  end

  def find_transactable
    @transactable = current_user.transactables.find(params[:transactable_id] || params[:project_id] || transactable_collaborator_params[:transactable_id])
  end

  def find_transactable_collaborator
    @transactable_collaborator = @transactable.transactable_collaborators.find(params[:id])
  end

  def transactable_collaborator_params
    params.require(:transactable_collaborator).permit(secured_params.transactable_collaborator)
  end
end
