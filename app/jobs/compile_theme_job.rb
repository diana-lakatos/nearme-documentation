# Job that handles precompiling and storing the theme stylesheet for a given
# owner.
class CompileThemeJob < Job
  def after_initialize(theme)
    @theme = theme
  end

  def perform
    Theme::Compiler.new(@theme).generate_and_update_assets
  end
end

