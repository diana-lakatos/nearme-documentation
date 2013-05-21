module LayoutHelper
  def render_content_outside_container?
    @render_content_outside_container
  end

  def render_content_outside_container!
    @render_content_outside_container = true
  end
end
