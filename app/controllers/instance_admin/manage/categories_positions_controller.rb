class InstanceAdmin::Manage::CategoriesPositionsController < InstanceAdmin::Manage::BaseController

  def update
    params[:category].each_with_index do |category, index|
      Category.find(category).change_child_index!(index)
    end

    render json: { success: true }
  end

end

