# frozen_string_literal: true
module SearcherHelper
  class ResultView
    delegate :==, to: :type

    def initialize(params, object)
      @object = object
      @params = params
    end

    def type
      valid_view? && view_name || default
    end

    def to_s
      type
    end

    private

    def view_name
      @params[:v] || @params[:result_view]
    end

    def valid_view?
      @object.available_search_views.include? view_name
    end

    def default
      @object.default_search_view
    end
  end

  def find_transactable_type
    if params[:transactable_type_class].in? Instance::SEARCHABLE_CLASSES
      @transactable_type = params[:transactable_type_class].constantize.find(params[:transactable_type_id]) if params[:transactable_type_id].present?
    elsif params[:transactable_type_id].present?
      @transactable_type = TransactableType.find(params[:transactable_type_id])
    end

    unless @transactable_type
      Instance::SEARCHABLE_CLASSES.each do |_klass|
        @transactable_type ||= _klass.constantize.searchable.by_position.first
      end
    end

    raise ActiveRecord::RecordNotFound, 'could not find transactable_type' unless @transactable_type

    # TODO: as a lookup context we use TransactableType, but search can by for
    # InstanceProfileType, this is temporary workaround. I think we need to add
    # IPT as a lookup_context for InstanceViews
    params[:transactable_type_id] ||= @transactable_type.id
    if @transactable_type.is_a?(TransactableType)
      lookup_context.try(:transactable_type_id=, @transactable_type.id) if respond_to?(:lookup_context)
    else
      lookup_context.try(:transactable_type_id=, TransactableType.first.id) if respond_to?(:lookup_context)
    end
  end

  def instantiate_searcher(params)
    InstanceType::TransactableSearchFactory.new(params).create
  end

  def search_breadcrumb(searcher)
    text = "#{searcher.result_count} results"
    text += " for \"#{@searcher.query}\"" if searcher.query.present?
    text
  end
end
