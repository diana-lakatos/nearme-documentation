# frozen_string_literal: true
module PlaceholderHelper
  def placeholder_url(width, height)
    expected_path = File.read(Rails.root.join('test/fixtures/placeholder_url.txt'))
    expected_path.strip.gsub('{{ width }}', width.to_s).gsub('{{ height }}', height.to_s)
  end
end
