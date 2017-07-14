# frozen_string_literal: true
module Api
  class V4::User::TransactablesController < V4::User::BaseController
    skip_before_action :require_authentication
    skip_before_action :require_authorization

    # TODO we need to get rid of this and convert this to custom json page
    def index
      params[:v] = 'listing_mixed'
      search_params = params
      @searcher = InstanceType::SearcherFactory.new(transactable_type, search_params, result_view, current_user).get_searcher
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
      if transactable_form.validate(params[:form].presence || params[:transactable] || {})
        transactable_form.save
        raise "Create failed due to configuration issue: #{form_model.errors.full_messages.join(', ')}" if form_model.changed?
        index_in_elastic_immediately(form_model)
      end
      respond(transactable_form, alert: false)
    end

    def update
      if transactable_form.validate(params[:form].presence || params[:transactable] || {})
        transactable_form.save
        # tmp safety check - we still have validation in Transactable model itself
        # so if model is invalid, it won't be saved and user won't be able to
        # sign up - we want to be notified
        raise "Update failed due to configuration issue: #{form_model.errors.full_messages.join(', ')}" if form_model.changed?
        index_in_elastic_immediately(form_model)
      end
      respond(transactable_form, alert: false)
    end

    def destroy
      transactable.destroy
      respond(transactable, alert: false)
    end

    private

    def transactable_form
      @transactable_form ||= form_configuration&.build(transactable)
    end

    def form_model
      transactable_form.model
    end

    def transactable
      @trasnactable ||= if params[:id]
                          current_user.transactables.find(params[:id])
                        else
                          transactable_type.transactables.build(creator: current_user)
      end.tap { |t| t.location_not_required = true }
    end

    def transactable_type
      @transactable_type ||= TransactableType.includes(:custom_attributes)
                                             .friendly
                                             .find_by(id: params[:transactable_type_id]) || first_transactable
    end

    def first_transactable
      TransactableType.includes(:custom_attributes).first
    end

    def result_view
      return @result_view = 'index' if PlatformContext.current.custom_theme.present?
      return @result_view = 'community' if PlatformContext.current.instance.is_community?
      @result_view = params[:v].presence
      @result_view = @result_view.in?(transactable_type.available_search_views) ? @result_view : transactable_type.default_search_view
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

    def index_in_elastic_immediately(record)
      return unless Rails.application.config.use_elastic_search

      Elastic::Commands::InstantIndexRecord.new(record).call
    end
  end
end
