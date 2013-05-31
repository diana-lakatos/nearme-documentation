# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :cucumber => true, :minitest => true, :test_unit => false, :rspec => false do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch('config/environments/test.rb')
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch('test/test_helper.rb') { :test_unit }
  watch(%r{features/support/}) { :cucumber }
end

guard 'minitest', :drb => true do
  watch(%r|^test/(.*)\/?(.*)\_test.rb|)
  watch(%r|^lib/(.*)\.rb|)             { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r|^lib/(.*)\.rb|)             { |m| "test/integration/#{m[1]}_test.rb" }
  watch(%r|^app/models/(.*)\.rb|)      { |m| "test/unit/#{m[1]}_test.rb" }
  watch(%r|^app/helpers/(.*)\.rb|)     { |m| "test/helpers/#{m[1]}_test.rb" }
  watch(%r|^app/controllers/(.*)\.rb|) { |m| "test/functional/#{m[1]}_test.rb" }
end

guard 'cucumber',:all_on_start => false, :cli => "--drb" do
  watch(%r{^features/.+\.feature$})
  #watch(%r{^features/support/.+$})          { 'features' }
  #watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'features' }
  watch(%r{^features/step_definitions/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] }
end
