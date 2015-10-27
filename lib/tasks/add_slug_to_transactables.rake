desc "Add slug to transactables"
task add_slug_to_transactables: :environment do
  Instance.find_each do |i|
    puts "-> Working on instance: #{i.domains.first.name}"
    i.set_context!

    # Friendly ID is wired up before_validation, so if a validation fails
    # such as photo validation, we wouldn't have a slug set.
    # Workaround: since #set_slug is private, we use #send and set it manually.
    #

    puts "  -> Transactables (#{Transactable.count})"
    Transactable.find_each do |t|
      t.send(:set_slug)
      t.save(validate: false)
    end

    puts "  -> Transactable Types (#{TransactableType.count})"
    TransactableType.find_each do |tt|
      tt.send(:set_slug)
      tt.save(validate: false)
    end

    puts "  -> Pages (#{Page.count})"
    Page.find_each do |p|
      unless p.slug.present?
        p.send(:set_slug)
        p.save(validate: false)
      end
    end
  end

  SitemapGeneratorJob.perform
end