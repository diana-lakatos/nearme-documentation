# frozen_string_literal: true
class Admin::Assets::TransactableTypeController < Admin::Assets::BaseController
  layout 'admin/default'

  def new
    @transactable_type = TransactableType.new
  end

  def create
    @transactable_type = ServiceType.new(transactable_type_params)

    if @transactable_type.save
      Utils::FormComponentsCreator.new(@transactable_type).create!
      @transactable_type.create_rating_systems

      flash[:success] = t 'admin.flash_messages.manage.liquid_views.created'

      if request.xhr?
        render json: { result: 'success', data: { redirect: admin_asset_general_settings_path(@transactable_type) } }
      else
        redirect_to admin_asset_general_settings_path(@transactable_type)
      end
    else
      if request.xhr?
        render json: { result: 'fail', data: @transactable_type.errors }
      else
        flash.now[:error] = @transactable_type.errors.full_messages.to_sentence
        render action: :new
      end
    end
  end

  def destroy
  end

  private

  def transactable_type_params
    params.require(:transactable_type).permit(secured_params.transactable_type)
  end
end
