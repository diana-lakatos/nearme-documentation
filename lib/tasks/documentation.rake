namespace :documentation do
  desc 'Generate user documentation'
  task user_docs: [:environment] do
    ddp = UserDocumentationGenerator.new
    ddp.generate_documentation
  end
end
