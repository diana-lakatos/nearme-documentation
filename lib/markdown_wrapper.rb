# frozen_string_literal: true
class MarkdownWrapper
  def initialize(text)
    @text = text
  end

  def to_html
    processor.render(@text.to_s)
  end

  private

  def processor
    @processor ||= Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      autolink: true,
      tables: true,
      no_intra_emphasis: true,
      quote: false
    )
  end
end
