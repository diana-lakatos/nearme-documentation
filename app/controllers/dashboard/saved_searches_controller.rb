class Dashboard::SavedSearchesController < Dashboard::BaseController
  def search
    @saved_search = current_user.saved_searches.find(params[:id])
    @saved_search.touch(:last_viewed_at)
    redirect_to @saved_search.path
  end

  def index
    @saved_searches = current_user.saved_searches.desc
  end

  def create
    if request.xhr?
      saved_search = current_user.saved_searches.build(saved_search_params)
      render json: { success: saved_search.save, title: saved_search.title }
    else
      fail ActionController::MethodNotAllowed
    end
  end

  def update
    if request.xhr?
      saved_search = current_user.saved_searches.find(params[:id])
      render json: { success: saved_search.update_attributes(saved_search_params), title: saved_search.title }
    else
      fail ActionController::MethodNotAllowed
    end
  end

  def destroy
    saved_search = current_user.saved_searches.find(params[:id])
    saved_search.destroy!
    redirect_to({ action: :index }, notice: t('flash_messages.dashboard.saved_searches.deleted'))
  end

  def change_alerts_frequency
    if request.xhr?
      current_user.update_column(:saved_searches_alerts_frequency, params[:alerts_frequency])
      render nothing: true
    else
      fail ActionController::MethodNotAllowed
    end
  end

  private

  def saved_search_params
    params.require(:saved_search).permit(secured_params.saved_search)
  end
end
