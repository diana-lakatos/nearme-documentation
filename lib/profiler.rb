class Profiler
  def self.profile(directory, name)
    if Rails.env.profiling?
      result = RubyProf.profile { yield }
      dir = File.join(Rails.root, 'tmp', 'performance', directory)
      FileUtils.mkdir_p(dir)
      file = File.join(dir, 'callgrind.%s.%s' % [name.parameterize, Time.now.to_s.parameterize])
      open(file, 'w') { |f| RubyProf::CallTreePrinter.new(result).print(f, min_percent: 1) }
    else
      yield
    end
  end
end
