# frozen_string_literal: true
class Admin::ConfigureController < Admin::BaseController
  def index
    @transactable_types = TransactableType.all
  end
end
