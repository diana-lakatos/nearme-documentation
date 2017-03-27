# frozen_string_literal: true
class RenderCustomPage
  def initialize(controller)
    @controller = controller
  end

  def render(page:, params: {}, submitted_form: nil)
    data_source_contents_scope = DataSourceContent.joins(:page_data_source_contents).where(page_data_source_contents: { page: page, slug: [nil, [params[:slug], params[:slug2], params[:slug3]].compact.join('/')] })
    @controller.instance_variable_set(:'@page', page)
    @controller.instance_variable_set(:'@data_source_last_update', data_source_contents_scope.maximum(:updated_at))
    @controller.instance_variable_set(:'@data_source_contents', data_source_contents_scope.paginate(page: params[:page].to_i.zero? ? 1 : params[:page].to_i, per_page: 20))
    # fc.build(User.new) needs to be updated - we should do some sort of mapping - i.e. know that
    # form 'Update Transactable' should be initialize with current_user.transactables.where(id: params[:transactable_id])
    # etc.

    forms = {}
    forms.merge!(submitted_form) if submitted_form.present?
    forms = forms.with_indifferent_access
    @controller.instance_variable_set(:'@forms', forms)
    @controller.instance_variable_set(:'@seo_params', SeoParams.create(params))
    if page.redirect?
      @controller.redirect_to page.redirect_url, status: page.redirect_code
    elsif params[:simple]
      @controller.render 'pages/simple', platform_context: [platform_context.decorate]
    elsif page.layout_name.blank? || params[:nolayout]
      @controller.render 'pages/show', layout: false
    else
      @controller.render 'pages/show', layout: page.layout_name
    end
  end
end
