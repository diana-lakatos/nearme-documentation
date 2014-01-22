module InstanceAdmin::InstanceAdminHelper

  def ico_for_flash(key)
    case key.to_s
    when 'notice' 
      "fa fa-check"
    when 'success'
      "fa fa-check"
    when 'error' 
      "fa fa-exclamation-triangle"
    when 'warning'
      "fa fa-exclamation-triangle"
    when 'deleted'
      "fa fa-times"
    end
  end
end
