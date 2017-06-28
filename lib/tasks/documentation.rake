namespace :documentation do
  desc 'Generate frontend documentation'
  task :frontend_docs do
    FileUtils.chdir(Rails.root)
    FileUtils.remove_dir(File.join(Rails.root, 'doc'), true)
    FileUtils.remove_dir(File.join(Rails.root, '.yardoc'), true)
    FileUtils.remove_dir(File.join(Rails.root, 'public', 'doc'), true)

    system("export RUBY_THREAD_VM_STACK_SIZE=5000000; bundle exec yard -e lib/yard_frontend_customizations.rb -p .yard/frontend_template/ --hide-tag todo --markup markdown 'app/drops/**/*.rb' 'lib/liquid_filters.rb' 'app/liquid_tags/*.rb' 'app/forms/**/*.rb'")

    FileUtils.remove_dir(File.join(Rails.root, '.yardoc'), true)
    FileUtils.remove_file(File.join(Rails.root, 'doc', 'file.README.html'), true)
    FileUtils.remove_file(File.join(Rails.root, 'doc', 'index.html'), true)
    FileUtils.cp(File.join(Rails.root, '.yard', 'frontend_doc_index.html'), File.join(Rails.root, 'doc', 'index.html'))
    FileUtils.mv(File.join(Rails.root, 'doc'), File.join(Rails.root, 'public'))
  end

  desc 'Generate frontend documentation'
  task :check_frontend_docs_coverage do
    FileUtils.chdir(Rails.root)
    FileUtils.remove_dir(File.join(Rails.root, '.yardoc'), true)

    system("yard stats -e lib/yard_stats_customizations.rb --list-undoc --plugin yard-activerecord 'app/drops/**/*.rb' 'lib/liquid_filters.rb' 'app/liquid_tags/*.rb'")

    FileUtils.remove_dir(File.join(Rails.root, '.yardoc'), true)
  end
end
