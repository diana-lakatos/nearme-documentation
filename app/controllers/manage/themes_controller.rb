class Manage::ThemesController < Manage::BaseController
  before_filter :find_theme

  def destroy_image
    @theme.send("remove_#{params[:name]}=", true)
    @theme.save!
    render :text => {}, :status => 200, :content_type => 'text/plain' 
  end

  private 
  def find_theme
    @theme = Theme.find(params[:id])
    redirect_to root_path unless @theme.owner_type == 'Company' && current_user.companies.map(&:id).include?(@theme.owner_id)
  end

end
