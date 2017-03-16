# frozen_string_literal: true
module Api
  class V4::User::TransactablesController < V4::User::BaseController
    before_action :find_transactable_type
    before_action :build_form, only: [:create, :update]
    skip_before_action :require_authentication
    skip_before_action :require_authorization

    def index
      params[:v] = 'listing_mixed'
      search_params = params
      @searcher = InstanceType::SearcherFactory.new(@transactable_type, search_params, result_view, current_user).get_searcher
      @searcher.paginate_results([(params[:page].presence || 1).to_i, 1].max, params[:per_page] || 20)
      render json: ApiSerializer.serialize_collection(
        @searcher.results.includes(categories: [:parent]),
        include: ['categories', 'action-type', 'action-type.pricings'],
        meta: { total_entries: @searcher.result_count, total_pages: @searcher.total_pages },
        links: pagination_links,
        namespace: ::V3
      )
    end

    def create
      if @transactable_form.validate(params[:form].presence || params[:transactable] || {})
        @transactable_form.save
        raise "Create failed due to configuration issue: #{@transactable_form.model.errors.full_messages.join(', ')}" unless @transactable_form.model.persisted?
      end
      respond(@transactable_form, alert: false,
                                  location: session.delete(:user_return_to).presence || params[:return_to].presence || root_path)
    end

    def update
      if @transactable_form.validate(params[:form].presence || params[:transactable] || {})
        @transactable_form.save
        # tmp safety check - we still have validation in Transactable model itself
        # so if model is invalid, it won't be saved and user won't be able to
        # sign up - we want to be notified
        raise "Update failed due to configuration issue: #{@transactable_form.model.errors.full_messages.join(', ')}" if @transactable_form.errors.any?
      end
      respond(@transactable_form, notice: I18n.t('flash_messages.api.users.update.notice'),
                                  alert: false)
    end

    private

    def build_form
      @form_configuration = FormConfiguration.find_by(id: params[:form_configuration_id]) if params[:form_configuration_id].present?
      @transactable_form = @form_configuration&.build(get_transactable)
    end

    def get_transactable
      if params[:id]
        current_user.transactables.find(params[:id])
      else
        @transactable_type.transactables.new
      end
    end

    def find_transactable_type
      @transactable_type = TransactableType.includes(:custom_attributes).friendly.find_by(id: params[:transactable_type_id]) || TransactableType.includes(:custom_attributes).first
    end

    def result_view
      return @result_view = 'index' if PlatformContext.current.custom_theme.present?
      return @result_view = 'community' if PlatformContext.current.instance.is_community?
      @result_view = params[:v].presence
      @result_view = @result_view.in?(@transactable_type.available_search_views) ? @result_view : @transactable_type.default_search_view
    end

    def pagination_links
      page = params[:page].to_pagination_number
      query = params.except(:page, :controller, :action)
      {
        first: api_transactables_url(query.merge(page: 1)),
        last: api_transactables_url(query.merge(page: @searcher.total_pages)),
        prev: page > 1 ? api_transactables_url(query.merge(page: page - 1)) : nil,
        next: page < @searcher.total_pages ? api_transactables_url(query.merge(page: page + 1)) : nil
      }
    end
  end
end
