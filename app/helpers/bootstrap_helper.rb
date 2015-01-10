module BootstrapHelper
  def render_modal(header, options={}, &block)
    content = capture(&block)
    content_tag :div, id: options[:id], class: "modal fade in", role: "dialog", tabindex: '-1', :"aria-hidden" => "true", data: {show: options[:autoload]} do
      content_tag :div, class: "modal-dialog" do
        content_tag :div, class: options[:bs2] ? "modal-body" : "modal-content" do
          modal_header(header, options) + content_tag(:div, content, {class: "modal-body clearfix"})
        end
      end
    end
  end

  def modal_header(header, options)
    content_tag :div, class: "modal-header" do
      content_tag( :button, content_tag(:span, raw("&#215;")), class: "close", :"aria-label" => "Close", data: {dismiss: 'modal'}) + 
      content_tag(:p, header, class: "modal-title")
    end
  end
end
