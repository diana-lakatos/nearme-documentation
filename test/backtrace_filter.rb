class BacktraceFilter
  def filter(backtrace)
    backtrace
    # backtrace.reject { |line| (line.include?('gems') || line.include?('<main>')) && !line.include?('custom_attributes') }
  end
end
