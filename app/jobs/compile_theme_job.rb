# Job that handles precompiling and storing the theme stylesheet for a given
# Instance.
class CompileThemeJob < Job
  def initialize(theme)
    @theme = theme
  end

  def perform
    Theme::Compiler.new(@theme).generate_and_update_assets
  end
end

