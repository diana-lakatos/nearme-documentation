module LayoutHelper
  def render_content_outside_container?
    @render_content_outside_container
  end

  def render_content_outside_container!
    @render_content_outside_container = true
  end

  def no_header_links?
    @no_header
  end

  def no_header_links!
    @no_header = true
  end

  def no_footer?
    @no_footer
  end

  def no_footer!
    @no_footer = true
  end
end
