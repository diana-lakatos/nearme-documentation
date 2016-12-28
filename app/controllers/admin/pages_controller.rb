# frozen_string_literal: true
class Admin::PagesController < Admin::BaseController
  def login
    render :login, layout: 'admin/login'
  end

  def register
    render :register, layout: 'admin/standalone'
  end

  def show
    if /^(advanced|asset|marketplace)_wizard/.match(params[:page])
      render params[:page], layout: 'admin/config'
    else
      render params[:page]
    end
  end
end
