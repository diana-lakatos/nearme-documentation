class HomeController < ApplicationController

  def index
    @transactable_types = current_instance.transactable_types
    @service_types = @transactable_types.select{|tt| tt.type == 'ServiceType'}
    @product_types = @transactable_types.select{|tt| tt.type == 'Spree::ProductType'}
  end

end

