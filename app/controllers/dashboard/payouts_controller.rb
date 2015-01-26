class Dashboard::PayoutsController < Dashboard::BaseController

  def edit
  end

  def update
    @company.assign_attributes(company_params)
    if @company.save
      flash[:success] = t('flash_messages.manage.payouts.updated')
      redirect_to action: :edit
    else
      render :edit
    end
  end

  private

  def company_params
    params.require(:company).permit(secured_params.company)
  end
end
