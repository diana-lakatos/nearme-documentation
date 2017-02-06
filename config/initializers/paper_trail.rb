# thanks to this we will know if we updated the record via console or rake task automagically.
PaperTrail::Rails::Engine.eager_load!

class PaperTrail::Version < ActiveRecord::Base
  if defined?(Rails::Console)
    PaperTrail.whodunnit = "#{`whoami`.strip}: console"
  elsif File.basename($PROGRAM_NAME) == 'rake'
    PaperTrail.whodunnit = "#{`whoami`.strip}: rake #{ARGV.join ' '}"
  end
end

PaperTrail.serializer = PaperTrail::Serializers::MixedJsonAndYamlSerializer
