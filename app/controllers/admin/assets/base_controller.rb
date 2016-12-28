# frozen_string_literal: true
class Admin::Assets::BaseController < Admin::BaseController
  layout 'admin/config'

  before_action :find_transactable_type, except: [:new, :create]

  private

  def find_transactable_type
    @transactable_type = TransactableType.find_by(slug: params[:slug])
  end
end
