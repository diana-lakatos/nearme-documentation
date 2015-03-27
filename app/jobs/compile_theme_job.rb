# Job that handles precompiling and storing the theme stylesheet for a given
# owner.
class CompileThemeJob < Job
  require 'benchmark'

  def after_initialize(theme)
    @theme = theme
  end

  def perform
  	Benchmark.bm do |bm|
      bm.report('Theme::Compiler'){Theme::Compiler.new(@theme).generate_and_update_assets}
    end
  end
end

