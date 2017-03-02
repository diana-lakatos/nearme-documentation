# frozen_string_literal: true
module LiquidViewService
  class Create
    def initialize(params)
      @params = params
    end

    def call
      save
      liquid_view
    end

    private

    def save
      liquid_view.save if liquid_view.valid?
    end

    def liquid_view
      @liquid_view ||= build_new_liquid_view
    end

    def build_new_liquid_view
      PlatformContext.current.instance.instance_views.build(attributes)
    end

    def attributes
      @params.merge! format: 'html', handler: 'liquid', view_type: InstanceView::VIEW_VIEW
    end
  end
end
