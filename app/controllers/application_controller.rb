class ApplicationController < ActionController::Base

  protect_from_forgery
  layout "new_layout"
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_filter :set_tabs

  private

  def set_tabs
  end

  # Some generic information on wizard for use accross controllers
  WizardInfo = Struct.new(:id, :url)

  # Return an object with information for a given wizard
  def wizard(name)
    return name if WizardInfo === name

    case name.to_s
    when 'space'
      WizardInfo.new(name.to_s, new_space_wizard_url)
    end
  end
  helper_method :wizard

  def redirect_for_wizard(wizard_id_or_object)
    redirect_to wizard(wizard_id_or_object).url
  end

  def not_found
    render "public/404", :status => :not_found
  end

end
