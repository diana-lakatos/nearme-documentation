class FeaturedItemsController < ApplicationController
  TARGET_WHITELIST = %w(transactables topics users)
  before_filter :check_valid_target

  def index
    request.format = :html
    @amount = params[:amount].presence || 1
    @type = params[:type]
    @partial_name = "featured_items/#{@target}"
    @collection = get_target_collection
  end

  protected

  def get_target_collection
    if @target == 'transactables'
      if @type.present?
        parent = TransactableType.where('lower(name) = ?', @type.downcase).first
        Transactable.where(transactable_type_id: parent.id).featured.take(@amount)
      else
        Transactable.featured.take(@amount)
      end
    else
      @target.classify.constantize.featured.take(@amount)
    end
  end

  def check_valid_target
    if params[:target].in? TARGET_WHITELIST
      @target = params[:target]
    else
      render(text: 'Invalid target provided.') && return
    end
  end
end
