namespace :documentation do
  desc 'Generate frontend documentation'
  task :frontend_docs do
    FileUtils.chdir(Rails.root)
    FileUtils.remove_dir(File.join(Rails.root, 'doc'), true)
    FileUtils.remove_dir(File.join(Rails.root, '.yardoc'), true)
    FileUtils.remove_dir(File.join(Rails.root, 'public', 'doc'), true)

    system("export RUBY_THREAD_VM_STACK_SIZE=5000000; yard -e lib/yard_frontend_customizations.rb -p .yard/frontend_template/ --hide-tag todo --plugin yard-activerecord --markup markdown 'app/**/*.rb' 'lib/liquid_filters.rb' 'app/liquid_tags/*.rb' 'db/schema.rb'")

    FileUtils.remove_dir(File.join(Rails.root, '.yardoc'), true)
    FileUtils.remove_file(File.join(Rails.root, 'doc', 'file.README.html'), true)
    FileUtils.remove_file(File.join(Rails.root, 'doc', 'index.html'), true)
    FileUtils.cp(File.join(Rails.root, '.yard', 'frontend_doc_index.html'), File.join(Rails.root, 'doc', 'index.html'))
    FileUtils.mv(File.join(Rails.root, 'doc'), File.join(Rails.root, 'public'))
  end
end
