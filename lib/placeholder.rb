# frozen_string_literal: true
class Placeholder
  def initialize(options = {}, _text = nil)
    @height = options[:height]
    @width = options[:width]
  end

  def path
    svg = "<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' viewBox='0 0 #{@width} #{@height}' width='#{@width}' height='#{@height}'><defs><symbol id='a' viewBox='0 0 90 66' opacity='0.3'><path d='M85 5v56H5V5h80m5-5H0v66h90V0z'/><circle cx='18' cy='20' r='6'/><path d='M56 14L37 39l-8-6-17 23h67z'/></symbol></defs><rect width='100%' height='100%' fill='#ccc'/><use xlink:href='#a' width='20%' x='40%'/></svg>"
    "data:image/svg+xml;charset=utf-8,#{URI.encode(svg)}"
  end
end
