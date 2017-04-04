# frozen_string_literal: true
class MarkdownWrapper
  def initialize(text)
    @text = text
  end

  def to_html
    processor.render(@text)
  end

  private

  def processor
    @processor ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
  end
end
