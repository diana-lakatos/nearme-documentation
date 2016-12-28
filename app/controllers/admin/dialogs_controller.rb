# frozen_string_literal: true
class Admin::DialogsController < Admin::BaseController
  layout 'admin/dialog'

  def show
    render params[:id]
  end
end
