class InstanceAdmin::Manage::RatingSystemsController < InstanceAdmin::Manage::BaseController
  def index
    @transactable_types = TransactableType.includes(:rating_systems).order(id: :asc).all
    @transactable_types.each do |transactable_type|
      transactable_type.rating_systems.each do |rating_system|
        unless rating_system.rating_questions.count == RatingConstants::MAX_QUESTIONS_QUANTITY
          rating_system.rating_questions.build 
        end
      end
    end
  end

  def update_systems
    @rating_systems = RatingSystem.all
    @rating_systems.each do |rating_system|
      rating_system.update(rating_system_params[rating_system.id.to_s])
    end
    redirect_to instance_admin_manage_rating_systems_path
  end 

  private

  def rating_system_params
    params.permit(secured_params.rating_systems).require(:rating_systems)
  end
end
