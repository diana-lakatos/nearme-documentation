# frozen_string_literal: true

private

def parse_top_comments_from_file
  return unless defined?(@readme) && @readme
  return @readme.contents unless @readme.filename =~ /\.rb$/
  data = String.new('')
  tokens = TokenList.new(@readme.contents)
  tokens.each do |token|
    break unless token.is_a?(RubyToken::TkCOMMENT) || token.is_a?(RubyToken::TkNL)
    data << (token.text[/\A#\s{0,1}(.*)/, 1] || "\n")
  end
  YARD::Docstring.new(data)
end
